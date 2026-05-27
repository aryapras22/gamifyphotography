// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BadgeModel _$BadgeModelFromJson(Map<String, dynamic> json) {
  return _BadgeModel.fromJson(json);
}

/// @nodoc
mixin _$BadgeModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;
  String get badgeType =>
      throw _privateConstructorUsedError; // "points" | "completed_levels" | "streak"
  int get requiredPoints => throw _privateConstructorUsedError;
  int get requiredLevels => throw _privateConstructorUsedError;
  int get requiredStreak => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this BadgeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeModelCopyWith<BadgeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeModelCopyWith<$Res> {
  factory $BadgeModelCopyWith(
    BadgeModel value,
    $Res Function(BadgeModel) then,
  ) = _$BadgeModelCopyWithImpl<$Res, BadgeModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String iconPath,
    String badgeType,
    int requiredPoints,
    int requiredLevels,
    int requiredStreak,
    bool isActive,
  });
}

/// @nodoc
class _$BadgeModelCopyWithImpl<$Res, $Val extends BadgeModel>
    implements $BadgeModelCopyWith<$Res> {
  _$BadgeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? iconPath = null,
    Object? badgeType = null,
    Object? requiredPoints = null,
    Object? requiredLevels = null,
    Object? requiredStreak = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            iconPath: null == iconPath
                ? _value.iconPath
                : iconPath // ignore: cast_nullable_to_non_nullable
                      as String,
            badgeType: null == badgeType
                ? _value.badgeType
                : badgeType // ignore: cast_nullable_to_non_nullable
                      as String,
            requiredPoints: null == requiredPoints
                ? _value.requiredPoints
                : requiredPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            requiredLevels: null == requiredLevels
                ? _value.requiredLevels
                : requiredLevels // ignore: cast_nullable_to_non_nullable
                      as int,
            requiredStreak: null == requiredStreak
                ? _value.requiredStreak
                : requiredStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeModelImplCopyWith<$Res>
    implements $BadgeModelCopyWith<$Res> {
  factory _$$BadgeModelImplCopyWith(
    _$BadgeModelImpl value,
    $Res Function(_$BadgeModelImpl) then,
  ) = __$$BadgeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String iconPath,
    String badgeType,
    int requiredPoints,
    int requiredLevels,
    int requiredStreak,
    bool isActive,
  });
}

/// @nodoc
class __$$BadgeModelImplCopyWithImpl<$Res>
    extends _$BadgeModelCopyWithImpl<$Res, _$BadgeModelImpl>
    implements _$$BadgeModelImplCopyWith<$Res> {
  __$$BadgeModelImplCopyWithImpl(
    _$BadgeModelImpl _value,
    $Res Function(_$BadgeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? iconPath = null,
    Object? badgeType = null,
    Object? requiredPoints = null,
    Object? requiredLevels = null,
    Object? requiredStreak = null,
    Object? isActive = null,
  }) {
    return _then(
      _$BadgeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        iconPath: null == iconPath
            ? _value.iconPath
            : iconPath // ignore: cast_nullable_to_non_nullable
                  as String,
        badgeType: null == badgeType
            ? _value.badgeType
            : badgeType // ignore: cast_nullable_to_non_nullable
                  as String,
        requiredPoints: null == requiredPoints
            ? _value.requiredPoints
            : requiredPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        requiredLevels: null == requiredLevels
            ? _value.requiredLevels
            : requiredLevels // ignore: cast_nullable_to_non_nullable
                  as int,
        requiredStreak: null == requiredStreak
            ? _value.requiredStreak
            : requiredStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeModelImpl implements _BadgeModel {
  _$BadgeModelImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    this.badgeType = 'points',
    this.requiredPoints = 0,
    this.requiredLevels = 0,
    this.requiredStreak = 0,
    this.isActive = true,
  });

  factory _$BadgeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String iconPath;
  @override
  @JsonKey()
  final String badgeType;
  // "points" | "completed_levels" | "streak"
  @override
  @JsonKey()
  final int requiredPoints;
  @override
  @JsonKey()
  final int requiredLevels;
  @override
  @JsonKey()
  final int requiredStreak;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'BadgeModel(id: $id, title: $title, description: $description, iconPath: $iconPath, badgeType: $badgeType, requiredPoints: $requiredPoints, requiredLevels: $requiredLevels, requiredStreak: $requiredStreak, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.badgeType, badgeType) ||
                other.badgeType == badgeType) &&
            (identical(other.requiredPoints, requiredPoints) ||
                other.requiredPoints == requiredPoints) &&
            (identical(other.requiredLevels, requiredLevels) ||
                other.requiredLevels == requiredLevels) &&
            (identical(other.requiredStreak, requiredStreak) ||
                other.requiredStreak == requiredStreak) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    iconPath,
    badgeType,
    requiredPoints,
    requiredLevels,
    requiredStreak,
    isActive,
  );

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeModelImplCopyWith<_$BadgeModelImpl> get copyWith =>
      __$$BadgeModelImplCopyWithImpl<_$BadgeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeModelImplToJson(this);
  }
}

abstract class _BadgeModel implements BadgeModel {
  factory _BadgeModel({
    required final String id,
    required final String title,
    required final String description,
    required final String iconPath,
    final String badgeType,
    final int requiredPoints,
    final int requiredLevels,
    final int requiredStreak,
    final bool isActive,
  }) = _$BadgeModelImpl;

  factory _BadgeModel.fromJson(Map<String, dynamic> json) =
      _$BadgeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get iconPath;
  @override
  String get badgeType; // "points" | "completed_levels" | "streak"
  @override
  int get requiredPoints;
  @override
  int get requiredLevels;
  @override
  int get requiredStreak;
  @override
  bool get isActive;

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeModelImplCopyWith<_$BadgeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
