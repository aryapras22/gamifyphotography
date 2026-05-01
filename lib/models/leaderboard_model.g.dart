// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  points: (json['points'] as num).toInt(),
  rank: (json['rank'] as num).toInt(),
);

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
  _$LeaderboardEntryImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'points': instance.points,
  'rank': instance.rank,
};
