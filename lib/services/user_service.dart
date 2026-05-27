import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/badge_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getUserProgress() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'user_1',
      name: 'Test User',
      email: 'test@test.com',
      points: 120,
      level: 2,
      earnedBadgeIds: ['b1'],
    );
  }

  Future<List<BadgeModel>> getBadges() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      BadgeModel(
        id: 'b1',
        title: 'Pemula',
        description: 'Menyelesaikan modul pertama',
        iconPath: 'assets/badges/b1.png',
        requiredPoints: 50,
      ),
      BadgeModel(
        id: 'b2',
        title: 'Menengah',
        description: 'Mencapai 200 poin',
        iconPath: 'assets/badges/b2.png',
        requiredPoints: 200,
      ),
    ];
  }

  /// Deducts [pointCost] from craftingBalance only (points stays unchanged).
  /// Increments bridgeProgress atomically.
  Future<bool> doCrafting({required String userId, required int pointCost}) async {
    final ref = _db.collection('users').doc(userId);
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) throw Exception('User not found');
        final data = snap.data()!;
        final currentBalance = (data['craftingBalance'] as int?) ?? 0;
        if (currentBalance < pointCost) throw Exception('Insufficient crafting balance');
        tx.update(ref, {
          'craftingBalance': currentBalance - pointCost,
          'bridgeProgress': ((data['bridgeProgress'] as int?) ?? 0) + 1,
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
