class TrackingEntity {
  final String ambulanceId;
  final String orderId;
  final double currentLatitude;
  final double currentLongitude;
  final double heading;
  final double speedKmh;
  final DateTime updatedAt;

  const TrackingEntity({
    required this.ambulanceId,
    required this.orderId,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.heading,
    required this.speedKmh,
    required this.updatedAt,
  });
}
