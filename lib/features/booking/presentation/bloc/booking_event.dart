abstract class BookingEvent {
  const BookingEvent();
}

class CreateOrderEvent extends BookingEvent {
  final String userId;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String? notes;

  const CreateOrderEvent({
    required this.userId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.notes,
  });
}

class LoadOrderDetailsEvent extends BookingEvent {
  final String orderId;

  const LoadOrderDetailsEvent(this.orderId);
}
