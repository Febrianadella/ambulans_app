import '../entities/order_entity.dart';
import '../entities/payment_entity.dart';

abstract class BookingRepository {
  Future<OrderEntity> createBooking({
    required String userId,
    required String pickupAddress,
    required String destinationAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? notes,
  });

  Future<OrderEntity> getOrderById(String orderId);
  Future<List<OrderEntity>> getUserOrders(String userId);
  Future<OrderEntity> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<PaymentEntity> submitPaymentProof(String orderId, String proofUrl);
}
