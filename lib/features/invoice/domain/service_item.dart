import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_item.freezed.dart';
part 'service_item.g.dart';

@freezed
class ServiceItem with _$ServiceItem {
  const ServiceItem._();

  const factory ServiceItem({
    required String id,
    required String name,
    required int quantity,
    required double unitPrice,
  }) = _ServiceItem;

  double get totalAmount => quantity * unitPrice;

  factory ServiceItem.fromJson(Map<String, dynamic> json) => _$ServiceItemFromJson(json);
}
