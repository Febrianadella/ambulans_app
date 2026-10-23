import '../../domain/entities/tracking_entity.dart';

class TrackingModel extends TrackingEntity {
  const TrackingModel({
    required super.ambulanceId,
    required super.orderId,
    required super.currentLatitude,
    required super.currentLongitude,
    required super.heading,
    required super.speedKmh,
    required super.updatedAt,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      ambulanceId:
          json['ambulanceId'] as String? ??
          json['ambulance_id'] as String? ??
          '',
      orderId: json['orderId'] as String? ?? json['order_id'] as String? ?? '',
      currentLatitude:
          (json['currentLatitude'] ?? json['current_latitude'] as num?)
              ?.toDouble() ??
          0.0,
      currentLongitude:
          (json['currentLongitude'] ?? json['current_longitude'] as num?)
              ?.toDouble() ??
          0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      speedKmh:
          (json['speedKmh'] ?? json['speed_kmh'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null
                ? DateTime.parse(json['updated_at'] as String)
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ambulanceId': ambulanceId,
      'orderId': orderId,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'heading': heading,
      'speedKmh': speedKmh,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
