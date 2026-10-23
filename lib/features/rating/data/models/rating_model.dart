import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.score,
    super.review,
    required super.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? json['order_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 5.0,
      review: json['review'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'score': score,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
