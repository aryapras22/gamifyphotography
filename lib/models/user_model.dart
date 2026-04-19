class UserModel {
  final String id;
  final String name;
  final String email;
  int points;
  int level;
  List<String> earnedBadgeIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.points = 0,
    this.level = 1,
    this.earnedBadgeIds = const [],
  });
}
