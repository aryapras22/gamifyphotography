import 'package:freezed_annotation/freezed_annotation.dart';

part 'bonus_mission_model.freezed.dart';
part 'bonus_mission_model.g.dart';

@freezed
class BonusMissionModel with _$BonusMissionModel {
  factory BonusMissionModel({
    required String id,
    required String title,
    required String description,

    // ── Page 1: Definisi & Contoh Foto ──────────────────────────────────
    @Default('') String page1Title,
    @Default('') String page1Description,
    @Default([]) List<String> page1ImageUrls,

    // ── Page 2: Instruksi & Visual Guide ────────────────────────────────
    @Default('') String page2WhenToUse,
    @Default('') String page2HowToUse,
    @Default('') String page2VisualGuideUrl, // SVG url untuk camera overlay

    // ── Metadata ────────────────────────────────────────────────────────
    @Default(0) int xpReward,
    @Default(0) int order, // urutan tampil di list
    @Default(false) bool isActive,
  }) = _BonusMissionModel;

  factory BonusMissionModel.fromJson(Map<String, dynamic> json) =>
      _$BonusMissionModelFromJson(json);
}
