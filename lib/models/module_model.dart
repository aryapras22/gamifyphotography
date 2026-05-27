import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

@freezed
class ModuleModel with _$ModuleModel {
  factory ModuleModel({
    required String id,
    required String title,
    required String description,
    @Default('') String materialContent, // teks materi (opsional — konten detail ada di levels)
    required int order,                  // urutan level
    @Default(false) bool isCompleted,
    @Default(0) int levelCount,          // jumlah level dalam modul (untuk tampilan UI)
    @Default([]) List<String> referenceImageUrls, // foto contoh dari firebase
    @Default('') String howToUse,        // cara penggunaan dari firebase (page2.howToUse)
    String? howToUseImageUrl,            // visual guide SVG/image dari firebase (page2.howToUseImageUrl)
    @Default('materi') String type,      // tipe modul: 'materi' atau 'quiz'
  }) = _ModuleModel;

  factory ModuleModel.fromJson(Map<String, dynamic> json) => _$ModuleModelFromJson(json);
}
