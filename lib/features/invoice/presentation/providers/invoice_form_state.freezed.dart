// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$InvoiceFormState {
  String get customerName => throw _privateConstructorUsedError;
  String get customerPhone => throw _privateConstructorUsedError;
  String get customerEmail => throw _privateConstructorUsedError;
  String get customerAddress => throw _privateConstructorUsedError;
  List<ServiceItem> get items => throw _privateConstructorUsedError;
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  double get amountPaid => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get showLogo => throw _privateConstructorUsedError;
  bool get showSignature => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get generatedInvoiceNumber => throw _privateConstructorUsedError;
  DateTime? get generatedInvoiceDate => throw _privateConstructorUsedError;

  /// Create a copy of InvoiceFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceFormStateCopyWith<InvoiceFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceFormStateCopyWith<$Res> {
  factory $InvoiceFormStateCopyWith(
    InvoiceFormState value,
    $Res Function(InvoiceFormState) then,
  ) = _$InvoiceFormStateCopyWithImpl<$Res, InvoiceFormState>;
  @useResult
  $Res call({
    String customerName,
    String customerPhone,
    String customerEmail,
    String customerAddress,
    List<ServiceItem> items,
    PaymentStatus paymentStatus,
    double amountPaid,
    bool isSubmitting,
    bool showLogo,
    bool showSignature,
    String? errorMessage,
    String? generatedInvoiceNumber,
    DateTime? generatedInvoiceDate,
  });
}

/// @nodoc
class _$InvoiceFormStateCopyWithImpl<$Res, $Val extends InvoiceFormState>
    implements $InvoiceFormStateCopyWith<$Res> {
  _$InvoiceFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvoiceFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerEmail = null,
    Object? customerAddress = null,
    Object? items = null,
    Object? paymentStatus = null,
    Object? amountPaid = null,
    Object? isSubmitting = null,
    Object? showLogo = null,
    Object? showSignature = null,
    Object? errorMessage = freezed,
    Object? generatedInvoiceNumber = freezed,
    Object? generatedInvoiceDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerPhone: null == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            customerEmail: null == customerEmail
                ? _value.customerEmail
                : customerEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            customerAddress: null == customerAddress
                ? _value.customerAddress
                : customerAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ServiceItem>,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as PaymentStatus,
            amountPaid: null == amountPaid
                ? _value.amountPaid
                : amountPaid // ignore: cast_nullable_to_non_nullable
                      as double,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            showLogo: null == showLogo
                ? _value.showLogo
                : showLogo // ignore: cast_nullable_to_non_nullable
                      as bool,
            showSignature: null == showSignature
                ? _value.showSignature
                : showSignature // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            generatedInvoiceNumber: freezed == generatedInvoiceNumber
                ? _value.generatedInvoiceNumber
                : generatedInvoiceNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            generatedInvoiceDate: freezed == generatedInvoiceDate
                ? _value.generatedInvoiceDate
                : generatedInvoiceDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvoiceFormStateImplCopyWith<$Res>
    implements $InvoiceFormStateCopyWith<$Res> {
  factory _$$InvoiceFormStateImplCopyWith(
    _$InvoiceFormStateImpl value,
    $Res Function(_$InvoiceFormStateImpl) then,
  ) = __$$InvoiceFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customerName,
    String customerPhone,
    String customerEmail,
    String customerAddress,
    List<ServiceItem> items,
    PaymentStatus paymentStatus,
    double amountPaid,
    bool isSubmitting,
    bool showLogo,
    bool showSignature,
    String? errorMessage,
    String? generatedInvoiceNumber,
    DateTime? generatedInvoiceDate,
  });
}

/// @nodoc
class __$$InvoiceFormStateImplCopyWithImpl<$Res>
    extends _$InvoiceFormStateCopyWithImpl<$Res, _$InvoiceFormStateImpl>
    implements _$$InvoiceFormStateImplCopyWith<$Res> {
  __$$InvoiceFormStateImplCopyWithImpl(
    _$InvoiceFormStateImpl _value,
    $Res Function(_$InvoiceFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvoiceFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerEmail = null,
    Object? customerAddress = null,
    Object? items = null,
    Object? paymentStatus = null,
    Object? amountPaid = null,
    Object? isSubmitting = null,
    Object? showLogo = null,
    Object? showSignature = null,
    Object? errorMessage = freezed,
    Object? generatedInvoiceNumber = freezed,
    Object? generatedInvoiceDate = freezed,
  }) {
    return _then(
      _$InvoiceFormStateImpl(
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerPhone: null == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        customerEmail: null == customerEmail
            ? _value.customerEmail
            : customerEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        customerAddress: null == customerAddress
            ? _value.customerAddress
            : customerAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ServiceItem>,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as PaymentStatus,
        amountPaid: null == amountPaid
            ? _value.amountPaid
            : amountPaid // ignore: cast_nullable_to_non_nullable
                  as double,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        showLogo: null == showLogo
            ? _value.showLogo
            : showLogo // ignore: cast_nullable_to_non_nullable
                  as bool,
        showSignature: null == showSignature
            ? _value.showSignature
            : showSignature // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        generatedInvoiceNumber: freezed == generatedInvoiceNumber
            ? _value.generatedInvoiceNumber
            : generatedInvoiceNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        generatedInvoiceDate: freezed == generatedInvoiceDate
            ? _value.generatedInvoiceDate
            : generatedInvoiceDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$InvoiceFormStateImpl extends _InvoiceFormState {
  const _$InvoiceFormStateImpl({
    this.customerName = '',
    this.customerPhone = '',
    this.customerEmail = '',
    this.customerAddress = '',
    final List<ServiceItem> items = const <ServiceItem>[],
    this.paymentStatus = PaymentStatus.unpaid,
    this.amountPaid = 0.0,
    this.isSubmitting = false,
    this.showLogo = true,
    this.showSignature = true,
    this.errorMessage,
    this.generatedInvoiceNumber,
    this.generatedInvoiceDate,
  }) : _items = items,
       super._();

  @override
  @JsonKey()
  final String customerName;
  @override
  @JsonKey()
  final String customerPhone;
  @override
  @JsonKey()
  final String customerEmail;
  @override
  @JsonKey()
  final String customerAddress;
  final List<ServiceItem> _items;
  @override
  @JsonKey()
  List<ServiceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final PaymentStatus paymentStatus;
  @override
  @JsonKey()
  final double amountPaid;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool showLogo;
  @override
  @JsonKey()
  final bool showSignature;
  @override
  final String? errorMessage;
  @override
  final String? generatedInvoiceNumber;
  @override
  final DateTime? generatedInvoiceDate;

  @override
  String toString() {
    return 'InvoiceFormState(customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, customerAddress: $customerAddress, items: $items, paymentStatus: $paymentStatus, amountPaid: $amountPaid, isSubmitting: $isSubmitting, showLogo: $showLogo, showSignature: $showSignature, errorMessage: $errorMessage, generatedInvoiceNumber: $generatedInvoiceNumber, generatedInvoiceDate: $generatedInvoiceDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceFormStateImpl &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.customerAddress, customerAddress) ||
                other.customerAddress == customerAddress) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.showLogo, showLogo) ||
                other.showLogo == showLogo) &&
            (identical(other.showSignature, showSignature) ||
                other.showSignature == showSignature) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.generatedInvoiceNumber, generatedInvoiceNumber) ||
                other.generatedInvoiceNumber == generatedInvoiceNumber) &&
            (identical(other.generatedInvoiceDate, generatedInvoiceDate) ||
                other.generatedInvoiceDate == generatedInvoiceDate));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerName,
    customerPhone,
    customerEmail,
    customerAddress,
    const DeepCollectionEquality().hash(_items),
    paymentStatus,
    amountPaid,
    isSubmitting,
    showLogo,
    showSignature,
    errorMessage,
    generatedInvoiceNumber,
    generatedInvoiceDate,
  );

  /// Create a copy of InvoiceFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceFormStateImplCopyWith<_$InvoiceFormStateImpl> get copyWith =>
      __$$InvoiceFormStateImplCopyWithImpl<_$InvoiceFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _InvoiceFormState extends InvoiceFormState {
  const factory _InvoiceFormState({
    final String customerName,
    final String customerPhone,
    final String customerEmail,
    final String customerAddress,
    final List<ServiceItem> items,
    final PaymentStatus paymentStatus,
    final double amountPaid,
    final bool isSubmitting,
    final bool showLogo,
    final bool showSignature,
    final String? errorMessage,
    final String? generatedInvoiceNumber,
    final DateTime? generatedInvoiceDate,
  }) = _$InvoiceFormStateImpl;
  const _InvoiceFormState._() : super._();

  @override
  String get customerName;
  @override
  String get customerPhone;
  @override
  String get customerEmail;
  @override
  String get customerAddress;
  @override
  List<ServiceItem> get items;
  @override
  PaymentStatus get paymentStatus;
  @override
  double get amountPaid;
  @override
  bool get isSubmitting;
  @override
  bool get showLogo;
  @override
  bool get showSignature;
  @override
  String? get errorMessage;
  @override
  String? get generatedInvoiceNumber;
  @override
  DateTime? get generatedInvoiceDate;

  /// Create a copy of InvoiceFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceFormStateImplCopyWith<_$InvoiceFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
