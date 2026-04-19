class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final int requiredPoints; // threshold poin untuk unlock

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.requiredPoints,
  });
}
