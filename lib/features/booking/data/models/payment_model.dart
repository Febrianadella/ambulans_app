import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.orderId,
    super.paymentProofUrl,
    required super.paymentStatus,
    super.amount,
    super.paymentMethod,
    super.paymentDate,
  });

  /// Factory constructor to create a [PaymentModel] from a JSON map.
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? json['order_id'] as String? ?? '',
      paymentProofUrl:
          json['paymentProofUrl'] as String? ??
          json['payment_proof_url'] as String?,
      paymentStatus:
          json['paymentStatus'] as String? ??
          json['payment_status'] as String? ??
          'menungguPembayaran',
      amount: (json['amount'] as num?)?.toDouble(),
      paymentMethod:
          json['paymentMethod'] as String? ?? json['payment_method'] as String?,
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'] as String)
          : (json['payment_date'] != null
                ? DateTime.tryParse(json['payment_date'] as String)
                : null),
    );
  }

  /// Converts this [PaymentModel] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentProofUrl': paymentProofUrl,
      'paymentStatus': paymentStatus,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate?.toIso8601String(),
    };
  }

  /// Creates a copy of this [PaymentModel] with updated fields.
  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? paymentProofUrl,
    String? paymentStatus,
    double? amount,
    String? paymentMethod,
    DateTime? paymentDate,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, orderId: $orderId, status: $paymentStatus)';
  }
}
