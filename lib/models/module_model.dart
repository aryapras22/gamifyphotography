class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String materialContent; // teks materi
  final int order;              // urutan level
  bool isCompleted;

  ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.materialContent,
    required this.order,
    this.isCompleted = false,
  });
}
