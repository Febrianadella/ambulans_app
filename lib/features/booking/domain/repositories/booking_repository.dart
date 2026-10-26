import '../entities/order_entity.dart';
import '../entities/payment_entity.dart';

abstract class BookingRepository {
  Future<OrderEntity> createBooking({
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
  });

  Future<OrderEntity> getOrderById(String orderId);
  Future<List<OrderEntity>> getUserOrders(String userId);
  Future<OrderEntity> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<PaymentEntity> submitPaymentProof(
    String orderId,
    String proofUrl, {
    String? paymentMethod,
    double? amount,
  });
  Future<PaymentEntity?> getPaymentByOrderId(String orderId);
  Future<OrderEntity> validatePayment(
    String orderId,
    bool isValid, {
    String? rejectionReason,
  });
  Future<List<OrderEntity>> getAllOrders();
}
