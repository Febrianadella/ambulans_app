import '../../domain/entities/tracking_entity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_datasource.dart';
import '../models/tracking_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remoteDataSource;

  TrackingRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<TrackingEntity> trackAmbulanceLocation(String ambulanceId) {
    return remoteDataSource.trackAmbulanceLocation(ambulanceId);
  }

  @override
  Future<void> updateDriverLocation({
    required String ambulanceId,
    required String orderId,
    required double latitude,
    required double longitude,
    required double heading,
    required double speedKmh,
  }) async {
    final model = TrackingModel(
      ambulanceId: ambulanceId,
      orderId: orderId,
      currentLatitude: latitude,
      currentLongitude: longitude,
      heading: heading,
      speedKmh: speedKmh,
      updatedAt: DateTime.now(),
    );
    await remoteDataSource.updateDriverLocation(model);
  }
}
