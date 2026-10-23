import '../entities/tracking_entity.dart';
import '../repositories/tracking_repository.dart';

class GetLiveLocationUseCase {
  final TrackingRepository repository;

  GetLiveLocationUseCase(this.repository);

  Stream<TrackingEntity> execute(String ambulanceId) {
    return repository.trackAmbulanceLocation(ambulanceId);
  }
}
