// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChallengeModel _$ChallengeModelFromJson(Map<String, dynamic> json) {
  return _ChallengeModel.fromJson(json);
}

/// @nodoc
mixin _$ChallengeModel {
  String get id => throw _privateConstructorUsedError;
  String get moduleId => throw _privateConstructorUsedError;
  String get instruction => throw _privateConstructorUsedError;
  int get pointReward => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get uploadedPhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this ChallengeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeModelCopyWith<ChallengeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeModelCopyWith<$Res> {
  factory $ChallengeModelCopyWith(
    ChallengeModel value,
    $Res Function(ChallengeModel) then,
  ) = _$ChallengeModelCopyWithImpl<$Res, ChallengeModel>;
  @useResult
  $Res call({
    String id,
    String moduleId,
    String instruction,
    int pointReward,
    bool isCompleted,
    String? uploadedPhotoUrl,
  });
}

/// @nodoc
class _$ChallengeModelCopyWithImpl<$Res, $Val extends ChallengeModel>
    implements $ChallengeModelCopyWith<$Res> {
  _$ChallengeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? instruction = null,
    Object? pointReward = null,
    Object? isCompleted = null,
    Object? uploadedPhotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            moduleId: null == moduleId
                ? _value.moduleId
                : moduleId // ignore: cast_nullable_to_non_nullable
                      as String,
            instruction: null == instruction
                ? _value.instruction
                : instruction // ignore: cast_nullable_to_non_nullable
                      as String,
            pointReward: null == pointReward
                ? _value.pointReward
                : pointReward // ignore: cast_nullable_to_non_nullable
                      as int,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            uploadedPhotoUrl: freezed == uploadedPhotoUrl
                ? _value.uploadedPhotoUrl
                : uploadedPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeModelImplCopyWith<$Res>
    implements $ChallengeModelCopyWith<$Res> {
  factory _$$ChallengeModelImplCopyWith(
    _$ChallengeModelImpl value,
    $Res Function(_$ChallengeModelImpl) then,
  ) = __$$ChallengeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String moduleId,
    String instruction,
    int pointReward,
    bool isCompleted,
    String? uploadedPhotoUrl,
  });
}

/// @nodoc
class __$$ChallengeModelImplCopyWithImpl<$Res>
    extends _$ChallengeModelCopyWithImpl<$Res, _$ChallengeModelImpl>
    implements _$$ChallengeModelImplCopyWith<$Res> {
  __$$ChallengeModelImplCopyWithImpl(
    _$ChallengeModelImpl _value,
    $Res Function(_$ChallengeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? instruction = null,
    Object? pointReward = null,
    Object? isCompleted = null,
    Object? uploadedPhotoUrl = freezed,
  }) {
    return _then(
      _$ChallengeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        moduleId: null == moduleId
            ? _value.moduleId
            : moduleId // ignore: cast_nullable_to_non_nullable
                  as String,
        instruction: null == instruction
            ? _value.instruction
            : instruction // ignore: cast_nullable_to_non_nullable
                  as String,
        pointReward: null == pointReward
            ? _value.pointReward
            : pointReward // ignore: cast_nullable_to_non_nullable
                  as int,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        uploadedPhotoUrl: freezed == uploadedPhotoUrl
            ? _value.uploadedPhotoUrl
            : uploadedPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeModelImpl implements _ChallengeModel {
  _$ChallengeModelImpl({
    required this.id,
    required this.moduleId,
    required this.instruction,
    required this.pointReward,
    this.isCompleted = false,
    this.uploadedPhotoUrl,
  });

  factory _$ChallengeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String moduleId;
  @override
  final String instruction;
  @override
  final int pointReward;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final String? uploadedPhotoUrl;

  @override
  String toString() {
    return 'ChallengeModel(id: $id, moduleId: $moduleId, instruction: $instruction, pointReward: $pointReward, isCompleted: $isCompleted, uploadedPhotoUrl: $uploadedPhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            (identical(other.pointReward, pointReward) ||
                other.pointReward == pointReward) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.uploadedPhotoUrl, uploadedPhotoUrl) ||
                other.uploadedPhotoUrl == uploadedPhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    moduleId,
    instruction,
    pointReward,
    isCompleted,
    uploadedPhotoUrl,
  );

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeModelImplCopyWith<_$ChallengeModelImpl> get copyWith =>
      __$$ChallengeModelImplCopyWithImpl<_$ChallengeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeModelImplToJson(this);
  }
}

abstract class _ChallengeModel implements ChallengeModel {
  factory _ChallengeModel({
    required final String id,
    required final String moduleId,
    required final String instruction,
    required final int pointReward,
    final bool isCompleted,
    final String? uploadedPhotoUrl,
  }) = _$ChallengeModelImpl;

  factory _ChallengeModel.fromJson(Map<String, dynamic> json) =
      _$ChallengeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get moduleId;
  @override
  String get instruction;
  @override
  int get pointReward;
  @override
  bool get isCompleted;
  @override
  String? get uploadedPhotoUrl;

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeModelImplCopyWith<_$ChallengeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
