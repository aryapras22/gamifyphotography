// lib/services/badge_service.dart
// TASK-03 — BadgeService (Mock)

import '../models/badge_model.dart';

class BadgeService {
  // ---------------------------------------------------------------------------
  // Konstanta ID Badge
  // ---------------------------------------------------------------------------

  static const kBadgeStarterId = 'badge_starter';
  static const kBadgeRookieId = 'badge_rookie';
  static const kBadgeVeteranId = 'badge_veteran';
  static const kBadgeSpecialMissionId = 'badge_special_mission';
  static const kBadgeSurvivorId = 'badge_survivor';

  // ---------------------------------------------------------------------------
  // Catalog badge (5 badge sesuai dokumen produk)
  // ---------------------------------------------------------------------------

  static final List<BadgeModel> _allBadges = [
    BadgeModel(
      id: kBadgeStarterId,
      title: 'Starter',
      description: 'Selesaikan misi pertama dan mulai perjalananmu!',
      iconPath: 'assets/images/badges/01_starter.svg',
      requiredPoints: 0,
    ),
    BadgeModel(
      id: kBadgeRookieId,
      title: 'Rookie',
      description: 'Capai level 15 — kamu sudah serius belajar fotografi!',
      iconPath: 'assets/images/badges/02_rookie.svg',
      requiredPoints: 0,
    ),
    BadgeModel(
      id: kBadgeVeteranId,
      title: 'Veteran',
      description: 'Capai level 30 — fotografer berpengalaman!',
      iconPath: 'assets/images/badges/03_veteran.svg',
      requiredPoints: 0,
    ),
    BadgeModel(
      id: kBadgeSpecialMissionId,
      title: 'Special Mission',
      description: 'Selesaikan special mission pertama (level 10).',
      iconPath: 'assets/images/badges/04_special_mission.svg',
      requiredPoints: 0,
    ),
    BadgeModel(
      id: kBadgeSurvivorId,
      title: 'Survivor',
      description: 'Login 7 hari berturut-turut — komitmen luar biasa!',
      iconPath: 'assets/images/badges/08_survivor.svg',
      requiredPoints: 0,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Kembalikan semua 5 badge yang tersedia.
  Future<List<BadgeModel>> getAllBadges() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_allBadges);
  }

  /// Kembalikan badge yang sudah dimiliki user berdasarkan [earnedBadgeIds].
  Future<List<BadgeModel>> getEarnedBadges(List<String> earnedBadgeIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allBadges
        .where((b) => earnedBadgeIds.contains(b.id))
        .toList();
  }

  /// Cek badge baru yang layak di-unlock, return list badge yang BARU saja
  /// unlock (belum ada di [earnedBadgeIds]).
  Future<List<BadgeModel>> checkNewBadges({
    required int level,
    required int streak,
    required List<String> earnedBadgeIds,
    required bool completedFirstMission,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final newBadges = <BadgeModel>[];

    for (final badge in _allBadges) {
      if (earnedBadgeIds.contains(badge.id)) continue;

      final earned = _isEligible(
        badgeId: badge.id,
        level: level,
        streak: streak,
        completedFirstMission: completedFirstMission,
      );
      if (earned) newBadges.add(badge);
    }

    return newBadges;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _isEligible({
    required String badgeId,
    required int level,
    required int streak,
    required bool completedFirstMission,
  }) {
    switch (badgeId) {
      case kBadgeStarterId:
        return completedFirstMission;
      case kBadgeRookieId:
        return level >= 15;
      case kBadgeVeteranId:
        return level >= 30;
      case kBadgeSpecialMissionId:
        return level >= 10;
      case kBadgeSurvivorId:
        return streak >= 7;
      default:
        return false;
    }
  }
}
