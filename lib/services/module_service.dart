import '../models/module_model.dart';

class ModuleService {
  Future<List<ModuleModel>> getModules() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      ModuleModel(
        id: 'm1',
        title: 'Komposisi Dasar',
        description: 'Pelajari dasar komposisi fotografi.',
        materialContent: 'Rule of thirds adalah dasar...',
        order: 1,
      ),
      ModuleModel(
        id: 'm2',
        title: 'Pencahayaan',
        description: 'Pentingnya cahaya dalam foto.',
        materialContent: 'Cahaya matahari pagi sangat baik...',
        order: 2,
      ),
    ];
  }
}
