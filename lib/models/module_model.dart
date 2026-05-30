import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

@freezed
class ModuleModel with _$ModuleModel {
  factory ModuleModel({
    required String id,
    required String title,
    required String description,
    @Default('') String materialContent, // teks materi (opsional)
    required int order,                   // urutan level
    @Default(false) bool isCompleted,
    @Default(0) int levelCount,
    @Default([]) List<String> referenceImageUrls, // foto contoh dari firebase
    @Default('') String howToUse,         // cara penggunaan (page2.howToUse)
    String? howToUseImageUrl,             // visual guide dari firebase
    @Default('materi') String type,       // tipe modul: 'materi' atau 'quiz'

    // ── Pre-quiz material (untuk quiz dengan materi WYSIWYG sebelumnya) ─────
    /// Jika true, tampilkan halaman materi sebelum quiz dimulai
    @Default(false) bool hasPreQuizMaterial,
    /// Konten rich text HTML untuk materi pra-quiz
    @Default('') String preQuizContent,
    /// Judul halaman materi pra-quiz
    @Default('') String preQuizTitle,
  }) = _ModuleModel;

  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);
}
