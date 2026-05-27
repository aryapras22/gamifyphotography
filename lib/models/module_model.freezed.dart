// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ModuleModel _$ModuleModelFromJson(Map<String, dynamic> json) {
  return _ModuleModel.fromJson(json);
}

/// @nodoc
mixin _$ModuleModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get materialContent =>
      throw _privateConstructorUsedError; // teks materi (opsional — konten detail ada di levels)
  int get order => throw _privateConstructorUsedError; // urutan level
  bool get isCompleted => throw _privateConstructorUsedError;
  int get levelCount =>
      throw _privateConstructorUsedError; // jumlah level dalam modul (untuk tampilan UI)
  List<String> get referenceImageUrls =>
      throw _privateConstructorUsedError; // foto contoh dari firebase
  String get howToUse =>
      throw _privateConstructorUsedError; // cara penggunaan dari firebase (page2.howToUse)
  String? get howToUseImageUrl =>
      throw _privateConstructorUsedError; // visual guide SVG/image dari firebase (page2.howToUseImageUrl)
  String get type => throw _privateConstructorUsedError;

  /// Serializes this ModuleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModuleModelCopyWith<ModuleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleModelCopyWith<$Res> {
  factory $ModuleModelCopyWith(
    ModuleModel value,
    $Res Function(ModuleModel) then,
  ) = _$ModuleModelCopyWithImpl<$Res, ModuleModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String materialContent,
    int order,
    bool isCompleted,
    int levelCount,
    List<String> referenceImageUrls,
    String howToUse,
    String? howToUseImageUrl,
    String type,
  });
}

/// @nodoc
class _$ModuleModelCopyWithImpl<$Res, $Val extends ModuleModel>
    implements $ModuleModelCopyWith<$Res> {
  _$ModuleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? materialContent = null,
    Object? order = null,
    Object? isCompleted = null,
    Object? levelCount = null,
    Object? referenceImageUrls = null,
    Object? howToUse = null,
    Object? howToUseImageUrl = freezed,
    Object? type = null,
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
            materialContent: null == materialContent
                ? _value.materialContent
                : materialContent // ignore: cast_nullable_to_non_nullable
                      as String,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            levelCount: null == levelCount
                ? _value.levelCount
                : levelCount // ignore: cast_nullable_to_non_nullable
                      as int,
            referenceImageUrls: null == referenceImageUrls
                ? _value.referenceImageUrls
                : referenceImageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            howToUse: null == howToUse
                ? _value.howToUse
                : howToUse // ignore: cast_nullable_to_non_nullable
                      as String,
            howToUseImageUrl: freezed == howToUseImageUrl
                ? _value.howToUseImageUrl
                : howToUseImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModuleModelImplCopyWith<$Res>
    implements $ModuleModelCopyWith<$Res> {
  factory _$$ModuleModelImplCopyWith(
    _$ModuleModelImpl value,
    $Res Function(_$ModuleModelImpl) then,
  ) = __$$ModuleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String materialContent,
    int order,
    bool isCompleted,
    int levelCount,
    List<String> referenceImageUrls,
    String howToUse,
    String? howToUseImageUrl,
    String type,
  });
}

/// @nodoc
class __$$ModuleModelImplCopyWithImpl<$Res>
    extends _$ModuleModelCopyWithImpl<$Res, _$ModuleModelImpl>
    implements _$$ModuleModelImplCopyWith<$Res> {
  __$$ModuleModelImplCopyWithImpl(
    _$ModuleModelImpl _value,
    $Res Function(_$ModuleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? materialContent = null,
    Object? order = null,
    Object? isCompleted = null,
    Object? levelCount = null,
    Object? referenceImageUrls = null,
    Object? howToUse = null,
    Object? howToUseImageUrl = freezed,
    Object? type = null,
  }) {
    return _then(
      _$ModuleModelImpl(
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
        materialContent: null == materialContent
            ? _value.materialContent
            : materialContent // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        levelCount: null == levelCount
            ? _value.levelCount
            : levelCount // ignore: cast_nullable_to_non_nullable
                  as int,
        referenceImageUrls: null == referenceImageUrls
            ? _value._referenceImageUrls
            : referenceImageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        howToUse: null == howToUse
            ? _value.howToUse
            : howToUse // ignore: cast_nullable_to_non_nullable
                  as String,
        howToUseImageUrl: freezed == howToUseImageUrl
            ? _value.howToUseImageUrl
            : howToUseImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleModelImpl implements _ModuleModel {
  _$ModuleModelImpl({
    required this.id,
    required this.title,
    required this.description,
    this.materialContent = '',
    required this.order,
    this.isCompleted = false,
    this.levelCount = 0,
    final List<String> referenceImageUrls = const [],
    this.howToUse = '',
    this.howToUseImageUrl,
    this.type = 'materi',
  }) : _referenceImageUrls = referenceImageUrls;

  factory _$ModuleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final String materialContent;
  // teks materi (opsional — konten detail ada di levels)
  @override
  final int order;
  // urutan level
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final int levelCount;
  // jumlah level dalam modul (untuk tampilan UI)
  final List<String> _referenceImageUrls;
  // jumlah level dalam modul (untuk tampilan UI)
  @override
  @JsonKey()
  List<String> get referenceImageUrls {
    if (_referenceImageUrls is EqualUnmodifiableListView)
      return _referenceImageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_referenceImageUrls);
  }

  // foto contoh dari firebase
  @override
  @JsonKey()
  final String howToUse;
  // cara penggunaan dari firebase (page2.howToUse)
  @override
  final String? howToUseImageUrl;
  // visual guide SVG/image dari firebase (page2.howToUseImageUrl)
  @override
  @JsonKey()
  final String type;

  @override
  String toString() {
    return 'ModuleModel(id: $id, title: $title, description: $description, materialContent: $materialContent, order: $order, isCompleted: $isCompleted, levelCount: $levelCount, referenceImageUrls: $referenceImageUrls, howToUse: $howToUse, howToUseImageUrl: $howToUseImageUrl, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.materialContent, materialContent) ||
                other.materialContent == materialContent) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.levelCount, levelCount) ||
                other.levelCount == levelCount) &&
            const DeepCollectionEquality().equals(
              other._referenceImageUrls,
              _referenceImageUrls,
            ) &&
            (identical(other.howToUse, howToUse) ||
                other.howToUse == howToUse) &&
            (identical(other.howToUseImageUrl, howToUseImageUrl) ||
                other.howToUseImageUrl == howToUseImageUrl) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    materialContent,
    order,
    isCompleted,
    levelCount,
    const DeepCollectionEquality().hash(_referenceImageUrls),
    howToUse,
    howToUseImageUrl,
    type,
  );

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleModelImplCopyWith<_$ModuleModelImpl> get copyWith =>
      __$$ModuleModelImplCopyWithImpl<_$ModuleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleModelImplToJson(this);
  }
}

abstract class _ModuleModel implements ModuleModel {
  factory _ModuleModel({
    required final String id,
    required final String title,
    required final String description,
    final String materialContent,
    required final int order,
    final bool isCompleted,
    final int levelCount,
    final List<String> referenceImageUrls,
    final String howToUse,
    final String? howToUseImageUrl,
    final String type,
  }) = _$ModuleModelImpl;

  factory _ModuleModel.fromJson(Map<String, dynamic> json) =
      _$ModuleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get materialContent; // teks materi (opsional — konten detail ada di levels)
  @override
  int get order; // urutan level
  @override
  bool get isCompleted;
  @override
  int get levelCount; // jumlah level dalam modul (untuk tampilan UI)
  @override
  List<String> get referenceImageUrls; // foto contoh dari firebase
  @override
  String get howToUse; // cara penggunaan dari firebase (page2.howToUse)
  @override
  String? get howToUseImageUrl; // visual guide SVG/image dari firebase (page2.howToUseImageUrl)
  @override
  String get type;

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModuleModelImplCopyWith<_$ModuleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
