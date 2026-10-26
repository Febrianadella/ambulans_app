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
    String? patientName,
    String? patientGender,
    int? patientAge,
    String? patientPhoneNumber,
    String? notes,
    String? serviceType,
    double? basePrice,
    double? additionalFee,
    double? totalPrice,
  }) async {
    return await repository.createBooking(
      userId: userId,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      patientName: patientName,
      patientGender: patientGender,
      patientAge: patientAge,
      patientPhoneNumber: patientPhoneNumber,
      notes: notes,
      serviceType: serviceType,
      basePrice: basePrice,
      additionalFee: additionalFee,
      totalPrice: totalPrice,
    );
  }
}
