import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;

  BookingBloc({required this.createBookingUseCase})
    : super(const BookingInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final order = await createBookingUseCase.execute(
        userId: event.userId,
        pickupAddress: event.pickupAddress,
        destinationAddress: event.destinationAddress,
        pickupLatitude: event.pickupLatitude,
        pickupLongitude: event.pickupLongitude,
        notes: event.notes,
      );
      emit(BookingCreatedSuccess(order));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
