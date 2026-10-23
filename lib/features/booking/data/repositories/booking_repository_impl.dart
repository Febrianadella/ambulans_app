import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/order_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderEntity> createBooking({
    required String userId,
    required String pickupAddress,
    required String destinationAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? notes,
  }) async {
    final orderModel = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      ambulanceId: '',
      driverId: '',
      status: OrderStatus.menungguPembayaran,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      createdAt: DateTime.now(),
    );

    return await remoteDataSource.createBooking(orderModel);
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    return await remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    return await remoteDataSource.getUserOrders(userId);
  }

  @override
  Future<OrderEntity> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    return await remoteDataSource.updateOrderStatus(orderId, newStatus);
  }

  @override
  Future<PaymentEntity> submitPaymentProof(
    String orderId,
    String proofUrl,
  ) async {
    return await remoteDataSource.submitPaymentProof(orderId, proofUrl);
  }
}
