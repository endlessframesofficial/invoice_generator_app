import 'package:freezed_annotation/freezed_annotation.dart';
import '../../customer/domain/customer.dart';
import 'service_item.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum PaymentStatus { paid, partiallyPaid, unpaid }

@freezed
class Invoice with _$Invoice {
  const Invoice._();

  const factory Invoice({
    required String invoiceNumber,
    required DateTime invoiceDate,
    required Customer customer,
    required List<ServiceItem> items,
    required PaymentStatus paymentStatus,
    required double amountPaid,
    @Default(true) bool showLogo,
    @Default(true) bool showSignature,
  }) = _Invoice;

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalAmount);
  double get balance => totalAmount - amountPaid;

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
}
