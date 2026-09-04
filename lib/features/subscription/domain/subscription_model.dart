enum PlanType { free, premium }
enum SubscriptionStatus { active, expired, cancelled, inactive }

class SubscriptionModel {
  final PlanType plan;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final String? purchaseToken;
  final String? productId;
  final DateTime? updatedAt;

  const SubscriptionModel({
    required this.plan,
    required this.status,
    this.expiresAt,
    this.purchaseToken,
    this.productId,
    this.updatedAt,
  });

  bool get isEntitledToPremium {
    if (plan != PlanType.premium) return false;
    if (status != SubscriptionStatus.active) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  factory SubscriptionModel.free() {
    return const SubscriptionModel(
      plan: PlanType.free,
      status: SubscriptionStatus.active,
    );
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: (json['plan'] == 'premium') ? PlanType.premium : PlanType.free,
      status: _parseStatus(json['status']),
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      purchaseToken: json['purchaseToken'] as String?,
      productId: json['productId'] as String?,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.name,
      'status': status.name,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (purchaseToken != null) 'purchaseToken': purchaseToken,
      if (productId != null) 'productId': productId,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static SubscriptionStatus _parseStatus(dynamic val) {
    switch (val?.toString().toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.inactive;
    }
  }
}
