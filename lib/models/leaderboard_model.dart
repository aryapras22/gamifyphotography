import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  factory LeaderboardEntry({
    required String userId,
    required String userName,
    required int points,
    required int rank,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
}
