import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../../domain/entities/order_entity.dart';

abstract class BookingRemoteDataSource {
  Future<OrderModel> createBooking(OrderModel order);
  Future<OrderModel> getOrderById(String orderId);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<PaymentModel> submitPaymentProof(String orderId, String proofUrl);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  @override
  Future<OrderModel> createBooking(OrderModel order) async {
    return order;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    return OrderModel(
      id: orderId,
      userId: 'USR-001',
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: OrderStatus.menungguValidasi,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    return [];
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    return OrderModel(
      id: orderId,
      userId: 'USR-001',
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: newStatus,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentModel> submitPaymentProof(
    String orderId,
    String proofUrl,
  ) async {
    return PaymentModel(
      id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      paymentProofUrl: proofUrl,
      paymentStatus: 'menungguValidasi',
      paymentDate: DateTime.now(),
    );
  }
}
