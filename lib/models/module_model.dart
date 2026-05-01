import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

@freezed
class ModuleModel with _$ModuleModel {
  factory ModuleModel({
    required String id,
    required String title,
    required String description,
    required String materialContent, // teks materi
    required int order,              // urutan level
    @Default(false) bool isCompleted,
  }) = _ModuleModel;

  factory ModuleModel.fromJson(Map<String, dynamic> json) => _$ModuleModelFromJson(json);
}
