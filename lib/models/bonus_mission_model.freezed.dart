// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bonus_mission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BonusMissionModel _$BonusMissionModelFromJson(Map<String, dynamic> json) {
  return _BonusMissionModel.fromJson(json);
}

/// @nodoc
mixin _$BonusMissionModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // ── Page 1: Definisi & Contoh Foto ──────────────────────────────────
  String get page1Title => throw _privateConstructorUsedError;
  String get page1Description => throw _privateConstructorUsedError;
  List<String> get page1ImageUrls =>
      throw _privateConstructorUsedError; // ── Page 2: Instruksi & Visual Guide ────────────────────────────────
  String get page2WhenToUse => throw _privateConstructorUsedError;
  String get page2HowToUse => throw _privateConstructorUsedError;
  String get page2VisualGuideUrl =>
      throw _privateConstructorUsedError; // SVG url untuk camera overlay
  // ── Metadata ────────────────────────────────────────────────────────
  int get xpReward => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError; // urutan tampil di list
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this BonusMissionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BonusMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BonusMissionModelCopyWith<BonusMissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BonusMissionModelCopyWith<$Res> {
  factory $BonusMissionModelCopyWith(
    BonusMissionModel value,
    $Res Function(BonusMissionModel) then,
  ) = _$BonusMissionModelCopyWithImpl<$Res, BonusMissionModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String page1Title,
    String page1Description,
    List<String> page1ImageUrls,
    String page2WhenToUse,
    String page2HowToUse,
    String page2VisualGuideUrl,
    int xpReward,
    int order,
    bool isActive,
  });
}

/// @nodoc
class _$BonusMissionModelCopyWithImpl<$Res, $Val extends BonusMissionModel>
    implements $BonusMissionModelCopyWith<$Res> {
  _$BonusMissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BonusMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? page1Title = null,
    Object? page1Description = null,
    Object? page1ImageUrls = null,
    Object? page2WhenToUse = null,
    Object? page2HowToUse = null,
    Object? page2VisualGuideUrl = null,
    Object? xpReward = null,
    Object? order = null,
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
            page1Title: null == page1Title
                ? _value.page1Title
                : page1Title // ignore: cast_nullable_to_non_nullable
                      as String,
            page1Description: null == page1Description
                ? _value.page1Description
                : page1Description // ignore: cast_nullable_to_non_nullable
                      as String,
            page1ImageUrls: null == page1ImageUrls
                ? _value.page1ImageUrls
                : page1ImageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            page2WhenToUse: null == page2WhenToUse
                ? _value.page2WhenToUse
                : page2WhenToUse // ignore: cast_nullable_to_non_nullable
                      as String,
            page2HowToUse: null == page2HowToUse
                ? _value.page2HowToUse
                : page2HowToUse // ignore: cast_nullable_to_non_nullable
                      as String,
            page2VisualGuideUrl: null == page2VisualGuideUrl
                ? _value.page2VisualGuideUrl
                : page2VisualGuideUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BonusMissionModelImplCopyWith<$Res>
    implements $BonusMissionModelCopyWith<$Res> {
  factory _$$BonusMissionModelImplCopyWith(
    _$BonusMissionModelImpl value,
    $Res Function(_$BonusMissionModelImpl) then,
  ) = __$$BonusMissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String page1Title,
    String page1Description,
    List<String> page1ImageUrls,
    String page2WhenToUse,
    String page2HowToUse,
    String page2VisualGuideUrl,
    int xpReward,
    int order,
    bool isActive,
  });
}

/// @nodoc
class __$$BonusMissionModelImplCopyWithImpl<$Res>
    extends _$BonusMissionModelCopyWithImpl<$Res, _$BonusMissionModelImpl>
    implements _$$BonusMissionModelImplCopyWith<$Res> {
  __$$BonusMissionModelImplCopyWithImpl(
    _$BonusMissionModelImpl _value,
    $Res Function(_$BonusMissionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BonusMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? page1Title = null,
    Object? page1Description = null,
    Object? page1ImageUrls = null,
    Object? page2WhenToUse = null,
    Object? page2HowToUse = null,
    Object? page2VisualGuideUrl = null,
    Object? xpReward = null,
    Object? order = null,
    Object? isActive = null,
  }) {
    return _then(
      _$BonusMissionModelImpl(
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
        page1Title: null == page1Title
            ? _value.page1Title
            : page1Title // ignore: cast_nullable_to_non_nullable
                  as String,
        page1Description: null == page1Description
            ? _value.page1Description
            : page1Description // ignore: cast_nullable_to_non_nullable
                  as String,
        page1ImageUrls: null == page1ImageUrls
            ? _value._page1ImageUrls
            : page1ImageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        page2WhenToUse: null == page2WhenToUse
            ? _value.page2WhenToUse
            : page2WhenToUse // ignore: cast_nullable_to_non_nullable
                  as String,
        page2HowToUse: null == page2HowToUse
            ? _value.page2HowToUse
            : page2HowToUse // ignore: cast_nullable_to_non_nullable
                  as String,
        page2VisualGuideUrl: null == page2VisualGuideUrl
            ? _value.page2VisualGuideUrl
            : page2VisualGuideUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
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
class _$BonusMissionModelImpl implements _BonusMissionModel {
  _$BonusMissionModelImpl({
    required this.id,
    required this.title,
    required this.description,
    this.page1Title = '',
    this.page1Description = '',
    final List<String> page1ImageUrls = const [],
    this.page2WhenToUse = '',
    this.page2HowToUse = '',
    this.page2VisualGuideUrl = '',
    this.xpReward = 0,
    this.order = 0,
    this.isActive = false,
  }) : _page1ImageUrls = page1ImageUrls;

  factory _$BonusMissionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BonusMissionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  // ── Page 1: Definisi & Contoh Foto ──────────────────────────────────
  @override
  @JsonKey()
  final String page1Title;
  @override
  @JsonKey()
  final String page1Description;
  final List<String> _page1ImageUrls;
  @override
  @JsonKey()
  List<String> get page1ImageUrls {
    if (_page1ImageUrls is EqualUnmodifiableListView) return _page1ImageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_page1ImageUrls);
  }

  // ── Page 2: Instruksi & Visual Guide ────────────────────────────────
  @override
  @JsonKey()
  final String page2WhenToUse;
  @override
  @JsonKey()
  final String page2HowToUse;
  @override
  @JsonKey()
  final String page2VisualGuideUrl;
  // SVG url untuk camera overlay
  // ── Metadata ────────────────────────────────────────────────────────
  @override
  @JsonKey()
  final int xpReward;
  @override
  @JsonKey()
  final int order;
  // urutan tampil di list
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'BonusMissionModel(id: $id, title: $title, description: $description, page1Title: $page1Title, page1Description: $page1Description, page1ImageUrls: $page1ImageUrls, page2WhenToUse: $page2WhenToUse, page2HowToUse: $page2HowToUse, page2VisualGuideUrl: $page2VisualGuideUrl, xpReward: $xpReward, order: $order, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BonusMissionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.page1Title, page1Title) ||
                other.page1Title == page1Title) &&
            (identical(other.page1Description, page1Description) ||
                other.page1Description == page1Description) &&
            const DeepCollectionEquality().equals(
              other._page1ImageUrls,
              _page1ImageUrls,
            ) &&
            (identical(other.page2WhenToUse, page2WhenToUse) ||
                other.page2WhenToUse == page2WhenToUse) &&
            (identical(other.page2HowToUse, page2HowToUse) ||
                other.page2HowToUse == page2HowToUse) &&
            (identical(other.page2VisualGuideUrl, page2VisualGuideUrl) ||
                other.page2VisualGuideUrl == page2VisualGuideUrl) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            (identical(other.order, order) || other.order == order) &&
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
    page1Title,
    page1Description,
    const DeepCollectionEquality().hash(_page1ImageUrls),
    page2WhenToUse,
    page2HowToUse,
    page2VisualGuideUrl,
    xpReward,
    order,
    isActive,
  );

  /// Create a copy of BonusMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BonusMissionModelImplCopyWith<_$BonusMissionModelImpl> get copyWith =>
      __$$BonusMissionModelImplCopyWithImpl<_$BonusMissionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BonusMissionModelImplToJson(this);
  }
}

abstract class _BonusMissionModel implements BonusMissionModel {
  factory _BonusMissionModel({
    required final String id,
    required final String title,
    required final String description,
    final String page1Title,
    final String page1Description,
    final List<String> page1ImageUrls,
    final String page2WhenToUse,
    final String page2HowToUse,
    final String page2VisualGuideUrl,
    final int xpReward,
    final int order,
    final bool isActive,
  }) = _$BonusMissionModelImpl;

  factory _BonusMissionModel.fromJson(Map<String, dynamic> json) =
      _$BonusMissionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description; // ── Page 1: Definisi & Contoh Foto ──────────────────────────────────
  @override
  String get page1Title;
  @override
  String get page1Description;
  @override
  List<String> get page1ImageUrls; // ── Page 2: Instruksi & Visual Guide ────────────────────────────────
  @override
  String get page2WhenToUse;
  @override
  String get page2HowToUse;
  @override
  String get page2VisualGuideUrl; // SVG url untuk camera overlay
  // ── Metadata ────────────────────────────────────────────────────────
  @override
  int get xpReward;
  @override
  int get order; // urutan tampil di list
  @override
  bool get isActive;

  /// Create a copy of BonusMissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BonusMissionModelImplCopyWith<_$BonusMissionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
