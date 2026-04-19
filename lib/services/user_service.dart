import '../models/user_model.dart';
import '../models/badge_model.dart';

class UserService {
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
  
  Future<bool> doCrafting(int pointCost) async {
     await Future.delayed(const Duration(seconds: 1));
     return true; // Asumsikan sukses
  }
}
