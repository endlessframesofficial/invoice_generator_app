// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      invoiceNumber: json['invoiceNumber'] as String,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
      amountPaid: (json['amountPaid'] as num).toDouble(),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'invoiceNumber': instance.invoiceNumber,
      'invoiceDate': instance.invoiceDate.toIso8601String(),
      'customer': instance.customer,
      'items': instance.items,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'amountPaid': instance.amountPaid,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.partiallyPaid: 'partiallyPaid',
  PaymentStatus.unpaid: 'unpaid',
};
