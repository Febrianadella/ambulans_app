import '../../domain/entities/order_entity.dart';

abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingCreatedSuccess extends BookingState {
  final OrderEntity order;

  const BookingCreatedSuccess(this.order);
}

class BookingLoadedSuccess extends BookingState {
  final OrderEntity order;

  const BookingLoadedSuccess(this.order);
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);
}
