import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/invoice.dart';
import '../../domain/service_item.dart';

part 'invoice_form_state.freezed.dart';

@freezed
class InvoiceFormState with _$InvoiceFormState {
  const InvoiceFormState._();

  const factory InvoiceFormState({
    @Default('') String customerName,
    @Default('') String customerPhone,
    @Default('') String customerEmail,
    @Default('') String customerAddress,
    @Default(<ServiceItem>[]) List<ServiceItem> items,
    @Default(PaymentStatus.unpaid) PaymentStatus paymentStatus,
    @Default(0.0) double amountPaid,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    String? generatedInvoiceNumber,
    DateTime? generatedInvoiceDate,
  }) = _InvoiceFormState;

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalAmount);
  
  bool get isValid {
    if (customerName.trim().isEmpty) return false;
    if (customerPhone.trim().isEmpty) return false;
    if (items.isEmpty) return false;
    for (final item in items) {
      if (item.name.trim().isEmpty) return false;
      if (item.quantity <= 0) return false;
      if (item.unitPrice <= 0) return false;
    }
    return true;
  }
}
