// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crafting_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CraftingItemModel _$CraftingItemModelFromJson(Map<String, dynamic> json) {
  return _CraftingItemModel.fromJson(json);
}

/// @nodoc
mixin _$CraftingItemModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get cost => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String get imagePath =>
      throw _privateConstructorUsedError; // Firebase Storage URL
  String get colorHex => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CraftingItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CraftingItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CraftingItemModelCopyWith<CraftingItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CraftingItemModelCopyWith<$Res> {
  factory $CraftingItemModelCopyWith(
    CraftingItemModel value,
    $Res Function(CraftingItemModel) then,
  ) = _$CraftingItemModelCopyWithImpl<$Res, CraftingItemModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int cost,
    int order,
    String imagePath,
    String colorHex,
    bool isActive,
  });
}

/// @nodoc
class _$CraftingItemModelCopyWithImpl<$Res, $Val extends CraftingItemModel>
    implements $CraftingItemModelCopyWith<$Res> {
  _$CraftingItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CraftingItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? cost = null,
    Object? order = null,
    Object? imagePath = null,
    Object? colorHex = null,
    Object? isActive = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            cost: null == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as int,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$CraftingItemModelImplCopyWith<$Res>
    implements $CraftingItemModelCopyWith<$Res> {
  factory _$$CraftingItemModelImplCopyWith(
    _$CraftingItemModelImpl value,
    $Res Function(_$CraftingItemModelImpl) then,
  ) = __$$CraftingItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int cost,
    int order,
    String imagePath,
    String colorHex,
    bool isActive,
  });
}

/// @nodoc
class __$$CraftingItemModelImplCopyWithImpl<$Res>
    extends _$CraftingItemModelCopyWithImpl<$Res, _$CraftingItemModelImpl>
    implements _$$CraftingItemModelImplCopyWith<$Res> {
  __$$CraftingItemModelImplCopyWithImpl(
    _$CraftingItemModelImpl _value,
    $Res Function(_$CraftingItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CraftingItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? cost = null,
    Object? order = null,
    Object? imagePath = null,
    Object? colorHex = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CraftingItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        cost: null == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as int,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$CraftingItemModelImpl implements _CraftingItemModel {
  _$CraftingItemModelImpl({
    required this.id,
    required this.name,
    this.description = '',
    required this.cost,
    required this.order,
    this.imagePath = '',
    this.colorHex = '#E9D5FF',
    this.isActive = true,
  });

  factory _$CraftingItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CraftingItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  final int cost;
  @override
  final int order;
  @override
  @JsonKey()
  final String imagePath;
  // Firebase Storage URL
  @override
  @JsonKey()
  final String colorHex;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'CraftingItemModel(id: $id, name: $name, description: $description, cost: $cost, order: $order, imagePath: $imagePath, colorHex: $colorHex, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CraftingItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    cost,
    order,
    imagePath,
    colorHex,
    isActive,
  );

  /// Create a copy of CraftingItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CraftingItemModelImplCopyWith<_$CraftingItemModelImpl> get copyWith =>
      __$$CraftingItemModelImplCopyWithImpl<_$CraftingItemModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CraftingItemModelImplToJson(this);
  }
}

abstract class _CraftingItemModel implements CraftingItemModel {
  factory _CraftingItemModel({
    required final String id,
    required final String name,
    final String description,
    required final int cost,
    required final int order,
    final String imagePath,
    final String colorHex,
    final bool isActive,
  }) = _$CraftingItemModelImpl;

  factory _CraftingItemModel.fromJson(Map<String, dynamic> json) =
      _$CraftingItemModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get cost;
  @override
  int get order;
  @override
  String get imagePath; // Firebase Storage URL
  @override
  String get colorHex;
  @override
  bool get isActive;

  /// Create a copy of CraftingItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CraftingItemModelImplCopyWith<_$CraftingItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
