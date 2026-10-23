import '../entities/tracking_entity.dart';

abstract class TrackingRepository {
  Stream<TrackingEntity> trackAmbulanceLocation(String ambulanceId);
  Future<void> updateDriverLocation({
    required String ambulanceId,
    required String orderId,
    required double latitude,
    required double longitude,
    required double heading,
    required double speedKmh,
  });
}
