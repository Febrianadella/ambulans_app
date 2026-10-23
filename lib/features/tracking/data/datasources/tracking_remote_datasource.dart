import '../models/tracking_model.dart';

abstract class TrackingRemoteDataSource {
  Stream<TrackingModel> trackAmbulanceLocation(String ambulanceId);
  Future<void> updateDriverLocation(TrackingModel tracking);
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  @override
  Stream<TrackingModel> trackAmbulanceLocation(String ambulanceId) async* {
    yield TrackingModel(
      ambulanceId: ambulanceId,
      orderId: 'ORD-101',
      currentLatitude: -6.2088,
      currentLongitude: 106.8456,
      heading: 90.0,
      speedKmh: 45.0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateDriverLocation(TrackingModel tracking) async {
    // Sinkronisasi koordinat GPS pengemudi ke WebSocket / Firebase
  }
}
