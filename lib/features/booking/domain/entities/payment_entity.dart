class PaymentEntity {
  final String id;
  final String orderId;
  final String? paymentProofUrl;
  final String paymentStatus;
  final double? amount;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? rejectionReason;

  const PaymentEntity({
    required this.id,
    required this.orderId,
    this.paymentProofUrl,
    required this.paymentStatus,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.rejectionReason,
  });
}
