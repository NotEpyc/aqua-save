class WaterBill {
  final double totalUsage;
  final double ratePerLiter;
  final DateTime billingDate;
  final bool isPaid;

  WaterBill({
    required this.totalUsage,
    required this.ratePerLiter,
    required this.billingDate,
    this.isPaid = false,
  });

  double get totalAmount => totalUsage * ratePerLiter;

  factory WaterBill.fromJson(Map<String, dynamic> json) {
    return WaterBill(
      totalUsage: (json['total_usage'] as num?)?.toDouble() ?? 0.0,
      ratePerLiter: (json['rate_per_liter'] as num?)?.toDouble() ?? 0.015,
      billingDate: DateTime.fromMillisecondsSinceEpoch(json['billing_date'] ?? 0),
      isPaid: json['is_paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_usage': totalUsage,
    'rate_per_liter': ratePerLiter,
    'billing_date': billingDate.millisecondsSinceEpoch,
    'is_paid': isPaid,
  };
}