import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.ambulanceId,
    required super.driverId,
    required super.status,
    super.pickupAddress,
    super.destinationAddress,
    super.pickupLatitude,
    super.pickupLongitude,
    super.destinationLatitude,
    super.destinationLongitude,
    super.totalPrice,
    super.createdAt,
  });

  /// Factory constructor to create an [OrderModel] from a JSON map.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      ambulanceId:
          json['ambulanceId'] as String? ??
          json['ambulance_id'] as String? ??
          '',
      driverId:
          json['driverId'] as String? ?? json['driver_id'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String?),
      pickupAddress:
          json['pickupAddress'] as String? ?? json['pickup_address'] as String?,
      destinationAddress:
          json['destinationAddress'] as String? ??
          json['destination_address'] as String?,
      pickupLatitude:
          (json['pickupLatitude'] ?? json['pickup_latitude'] as num?)
              ?.toDouble(),
      pickupLongitude:
          (json['pickupLongitude'] ?? json['pickup_longitude'] as num?)
              ?.toDouble(),
      destinationLatitude:
          (json['destinationLatitude'] ?? json['destination_latitude'] as num?)
              ?.toDouble(),
      destinationLongitude:
          (json['destinationLongitude'] ??
                  json['destination_longitude'] as num?)
              ?.toDouble(),
      totalPrice: (json['totalPrice'] ?? json['total_price'] as num?)
          ?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'] as String)
                : null),
    );
  }

  /// Converts this [OrderModel] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'ambulanceId': ambulanceId,
      'driverId': driverId,
      'status': status.value,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'totalPrice': totalPrice,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [OrderModel] with updated fields.
  OrderModel copyWith({
    String? id,
    String? userId,
    String? ambulanceId,
    String? driverId,
    OrderStatus? status,
    String? pickupAddress,
    String? destinationAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, ambulanceId: $ambulanceId, driverId: $driverId, status: ${status.value})';
  }
}
