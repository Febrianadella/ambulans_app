class RatingEntity {
  final String id;
  final String orderId;
  final String userId;
  final double score; // 1 to 5
  final String? review;
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.score,
    this.review,
    required this.createdAt,
  });
}
