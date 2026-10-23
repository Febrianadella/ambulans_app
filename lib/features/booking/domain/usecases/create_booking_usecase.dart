import '../entities/order_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<OrderEntity> execute({
    required String userId,
    required String pickupAddress,
    required String destinationAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? notes,
  }) async {
    return await repository.createBooking(
      userId: userId,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      notes: notes,
    );
  }
}
