// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  List<String> get earnedBadgeIds => throw _privateConstructorUsedError;
  List<String> get completedPhotoUrls => throw _privateConstructorUsedError;
  int get bridgeProgress => throw _privateConstructorUsedError;
  List<String> get completedModuleIds => throw _privateConstructorUsedError;
  int get streakCount => throw _privateConstructorUsedError;
  DateTime? get lastLoginDate => throw _privateConstructorUsedError;
  List<bool> get weekHistory => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String email,
    String role,
    int points,
    int level,
    List<String> earnedBadgeIds,
    List<String> completedPhotoUrls,
    int bridgeProgress,
    List<String> completedModuleIds,
    int streakCount,
    DateTime? lastLoginDate,
    List<bool> weekHistory,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? points = null,
    Object? level = null,
    Object? earnedBadgeIds = null,
    Object? completedPhotoUrls = null,
    Object? bridgeProgress = null,
    Object? completedModuleIds = null,
    Object? streakCount = null,
    Object? lastLoginDate = freezed,
    Object? weekHistory = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            earnedBadgeIds: null == earnedBadgeIds
                ? _value.earnedBadgeIds
                : earnedBadgeIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            completedPhotoUrls: null == completedPhotoUrls
                ? _value.completedPhotoUrls
                : completedPhotoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            bridgeProgress: null == bridgeProgress
                ? _value.bridgeProgress
                : bridgeProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            completedModuleIds: null == completedModuleIds
                ? _value.completedModuleIds
                : completedModuleIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            streakCount: null == streakCount
                ? _value.streakCount
                : streakCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastLoginDate: freezed == lastLoginDate
                ? _value.lastLoginDate
                : lastLoginDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            weekHistory: null == weekHistory
                ? _value.weekHistory
                : weekHistory // ignore: cast_nullable_to_non_nullable
                      as List<bool>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String email,
    String role,
    int points,
    int level,
    List<String> earnedBadgeIds,
    List<String> completedPhotoUrls,
    int bridgeProgress,
    List<String> completedModuleIds,
    int streakCount,
    DateTime? lastLoginDate,
    List<bool> weekHistory,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? points = null,
    Object? level = null,
    Object? earnedBadgeIds = null,
    Object? completedPhotoUrls = null,
    Object? bridgeProgress = null,
    Object? completedModuleIds = null,
    Object? streakCount = null,
    Object? lastLoginDate = freezed,
    Object? weekHistory = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        earnedBadgeIds: null == earnedBadgeIds
            ? _value._earnedBadgeIds
            : earnedBadgeIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        completedPhotoUrls: null == completedPhotoUrls
            ? _value._completedPhotoUrls
            : completedPhotoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        bridgeProgress: null == bridgeProgress
            ? _value.bridgeProgress
            : bridgeProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        completedModuleIds: null == completedModuleIds
            ? _value._completedModuleIds
            : completedModuleIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        streakCount: null == streakCount
            ? _value.streakCount
            : streakCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastLoginDate: freezed == lastLoginDate
            ? _value.lastLoginDate
            : lastLoginDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        weekHistory: null == weekHistory
            ? _value._weekHistory
            : weekHistory // ignore: cast_nullable_to_non_nullable
                  as List<bool>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  _$UserModelImpl({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.points = 0,
    this.level = 1,
    final List<String> earnedBadgeIds = const [],
    final List<String> completedPhotoUrls = const [],
    this.bridgeProgress = 0,
    final List<String> completedModuleIds = const [],
    this.streakCount = 0,
    this.lastLoginDate,
    final List<bool> weekHistory = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    this.createdAt,
  }) : _earnedBadgeIds = earnedBadgeIds,
       _completedPhotoUrls = completedPhotoUrls,
       _completedModuleIds = completedModuleIds,
       _weekHistory = weekHistory;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int level;
  final List<String> _earnedBadgeIds;
  @override
  @JsonKey()
  List<String> get earnedBadgeIds {
    if (_earnedBadgeIds is EqualUnmodifiableListView) return _earnedBadgeIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnedBadgeIds);
  }

  final List<String> _completedPhotoUrls;
  @override
  @JsonKey()
  List<String> get completedPhotoUrls {
    if (_completedPhotoUrls is EqualUnmodifiableListView)
      return _completedPhotoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedPhotoUrls);
  }

  @override
  @JsonKey()
  final int bridgeProgress;
  final List<String> _completedModuleIds;
  @override
  @JsonKey()
  List<String> get completedModuleIds {
    if (_completedModuleIds is EqualUnmodifiableListView)
      return _completedModuleIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedModuleIds);
  }

  @override
  @JsonKey()
  final int streakCount;
  @override
  final DateTime? lastLoginDate;
  final List<bool> _weekHistory;
  @override
  @JsonKey()
  List<bool> get weekHistory {
    if (_weekHistory is EqualUnmodifiableListView) return _weekHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekHistory);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, points: $points, level: $level, earnedBadgeIds: $earnedBadgeIds, completedPhotoUrls: $completedPhotoUrls, bridgeProgress: $bridgeProgress, completedModuleIds: $completedModuleIds, streakCount: $streakCount, lastLoginDate: $lastLoginDate, weekHistory: $weekHistory, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(
              other._earnedBadgeIds,
              _earnedBadgeIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._completedPhotoUrls,
              _completedPhotoUrls,
            ) &&
            (identical(other.bridgeProgress, bridgeProgress) ||
                other.bridgeProgress == bridgeProgress) &&
            const DeepCollectionEquality().equals(
              other._completedModuleIds,
              _completedModuleIds,
            ) &&
            (identical(other.streakCount, streakCount) ||
                other.streakCount == streakCount) &&
            (identical(other.lastLoginDate, lastLoginDate) ||
                other.lastLoginDate == lastLoginDate) &&
            const DeepCollectionEquality().equals(
              other._weekHistory,
              _weekHistory,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    role,
    points,
    level,
    const DeepCollectionEquality().hash(_earnedBadgeIds),
    const DeepCollectionEquality().hash(_completedPhotoUrls),
    bridgeProgress,
    const DeepCollectionEquality().hash(_completedModuleIds),
    streakCount,
    lastLoginDate,
    const DeepCollectionEquality().hash(_weekHistory),
    createdAt,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  factory _UserModel({
    required final String id,
    required final String name,
    required final String email,
    final String role,
    final int points,
    final int level,
    final List<String> earnedBadgeIds,
    final List<String> completedPhotoUrls,
    final int bridgeProgress,
    final List<String> completedModuleIds,
    final int streakCount,
    final DateTime? lastLoginDate,
    final List<bool> weekHistory,
    final DateTime? createdAt,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String get role;
  @override
  int get points;
  @override
  int get level;
  @override
  List<String> get earnedBadgeIds;
  @override
  List<String> get completedPhotoUrls;
  @override
  int get bridgeProgress;
  @override
  List<String> get completedModuleIds;
  @override
  int get streakCount;
  @override
  DateTime? get lastLoginDate;
  @override
  List<bool> get weekHistory;
  @override
  DateTime? get createdAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
