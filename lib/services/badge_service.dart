// lib/services/badge_service.dart
// Firestore-driven badge service with auto-award logic

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';

class BadgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetch all active badges from Firestore.
  Future<List<BadgeModel>> getAllBadges() async {
    final snap = await _db
        .collection('badges')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs
        .map((d) => BadgeModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  /// Fetch badges that the user has earned.
  Future<List<BadgeModel>> getEarnedBadges(List<String> earnedBadgeIds) async {
    if (earnedBadgeIds.isEmpty) return [];
    final all = await getAllBadges();
    return all.where((b) => earnedBadgeIds.contains(b.id)).toList();
  }

  /// Check and auto-award badges based on user progress.
  /// Returns list of newly awarded badge IDs.
  Future<List<BadgeModel>> checkAndAwardBadges(UserModel user) async {
    final snap = await _db
        .collection('badges')
        .where('isActive', isEqualTo: true)
        .get();

    final badges = snap.docs
        .map((d) => BadgeModel.fromJson({...d.data(), 'id': d.id}))
        .toList();

    final newBadges = <BadgeModel>[];

    for (final badge in badges) {
      if (user.earnedBadgeIds.contains(badge.id)) continue; // already earned

      bool earned = false;
      switch (badge.badgeType) {
        case 'points':
          earned = user.points >= badge.requiredPoints;
          break;
        case 'completed_levels':
          earned = user.completedLevels.length >= badge.requiredLevels;
          break;
        case 'streak':
          earned = user.streakCount >= badge.requiredStreak;
          break;
      }

      if (earned) newBadges.add(badge);
    }

    if (newBadges.isEmpty) return [];

    // Persist to Firestore
    await persistNewBadges(userId: user.id, newBadges: newBadges);

    return newBadges;
  }

  /// Persist badge that baru di-unlock ke Firestore.
  ///
  /// Menulis ke DUA tempat secara atomik (batch):
  ///   1. `users/{uid}.earnedBadgeIds` — array field (dibaca Flutter)
  ///   2. `users/{uid}/badges/{badgeId}` — subcollection (dibaca admin)
  ///
  /// Idempotent: aman dipanggil berkali-kali untuk badge yang sama.
  Future<void> persistNewBadges({
    required String userId,
    required List<BadgeModel> newBadges,
  }) async {
    if (newBadges.isEmpty) return;

    final userRef = _db.collection('users').doc(userId);
    final batch = _db.batch();

    // 1. Append badge IDs to the earnedBadgeIds array on the user doc
    batch.update(userRef, {
      'earnedBadgeIds': FieldValue.arrayUnion(
        newBadges.map((b) => b.id).toList(),
      ),
    });

    // 2. Write each badge as a document in the badges subcollection
    for (final badge in newBadges) {
      final badgeRef = userRef.collection('badges').doc(badge.id);
      batch.set(
        badgeRef,
        {
          'id': badge.id,
          'title': badge.title,
          'description': badge.description,
          'iconPath': badge.iconPath,
          'earnedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Legacy compatibility: check new badges based on level/streak (for existing callers).
  Future<List<BadgeModel>> checkNewBadges({
    required int level,
    required int streak,
    required List<String> earnedBadgeIds,
    required bool completedFirstMission,
  }) async {
    final all = await getAllBadges();
    final newBadges = <BadgeModel>[];

    for (final badge in all) {
      if (earnedBadgeIds.contains(badge.id)) continue;

      bool earned = false;
      switch (badge.badgeType) {
        case 'points':
          // For legacy compatibility, use level * 100 as approximate points
          earned = (level * 100) >= badge.requiredPoints;
          break;
        case 'completed_levels':
          earned = level >= badge.requiredLevels;
          break;
        case 'streak':
          earned = streak >= badge.requiredStreak;
          break;
      }

      if (earned) newBadges.add(badge);
    }

    return newBadges;
  }
}
