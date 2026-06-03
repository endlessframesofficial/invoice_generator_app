// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServiceItem _$ServiceItemFromJson(Map<String, dynamic> json) {
  return _ServiceItem.fromJson(json);
}

/// @nodoc
mixin _$ServiceItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;

  /// Serializes this ServiceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceItemCopyWith<ServiceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceItemCopyWith<$Res> {
  factory $ServiceItemCopyWith(
    ServiceItem value,
    $Res Function(ServiceItem) then,
  ) = _$ServiceItemCopyWithImpl<$Res, ServiceItem>;
  @useResult
  $Res call({String id, String name, int quantity, double unitPrice});
}

/// @nodoc
class _$ServiceItemCopyWithImpl<$Res, $Val extends ServiceItem>
    implements $ServiceItemCopyWith<$Res> {
  _$ServiceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? unitPrice = null,
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
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceItemImplCopyWith<$Res>
    implements $ServiceItemCopyWith<$Res> {
  factory _$$ServiceItemImplCopyWith(
    _$ServiceItemImpl value,
    $Res Function(_$ServiceItemImpl) then,
  ) = __$$ServiceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int quantity, double unitPrice});
}

/// @nodoc
class __$$ServiceItemImplCopyWithImpl<$Res>
    extends _$ServiceItemCopyWithImpl<$Res, _$ServiceItemImpl>
    implements _$$ServiceItemImplCopyWith<$Res> {
  __$$ServiceItemImplCopyWithImpl(
    _$ServiceItemImpl _value,
    $Res Function(_$ServiceItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _$ServiceItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceItemImpl extends _ServiceItem {
  const _$ServiceItemImpl({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  }) : super._();

  factory _$ServiceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int quantity;
  @override
  final double unitPrice;

  @override
  String toString() {
    return 'ServiceItem(id: $id, name: $name, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, quantity, unitPrice);

  /// Create a copy of ServiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceItemImplCopyWith<_$ServiceItemImpl> get copyWith =>
      __$$ServiceItemImplCopyWithImpl<_$ServiceItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceItemImplToJson(this);
  }
}

abstract class _ServiceItem extends ServiceItem {
  const factory _ServiceItem({
    required final String id,
    required final String name,
    required final int quantity,
    required final double unitPrice,
  }) = _$ServiceItemImpl;
  const _ServiceItem._() : super._();

  factory _ServiceItem.fromJson(Map<String, dynamic> json) =
      _$ServiceItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get quantity;
  @override
  double get unitPrice;

  /// Create a copy of ServiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceItemImplCopyWith<_$ServiceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
