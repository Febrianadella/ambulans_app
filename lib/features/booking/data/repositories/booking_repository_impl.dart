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
    final now = DateTime.now();
    final randomSuffix = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
    final uniqueOrderId =
        'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$randomSuffix';

    final orderModel = OrderModel(
      id: uniqueOrderId,
      userId: userId,
      ambulanceId: 'AMB-101',
      driverId: 'DVR-202',
      status: OrderStatus.menungguPembayaran,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      patientName: patientName,
      patientGender: patientGender,
      patientAge: patientAge,
      patientPhoneNumber: patientPhoneNumber,
      notes: notes,
      serviceType: serviceType ?? 'Ambulans Gawat Darurat (Emergency)',
      basePrice: basePrice ?? 150000.0,
      additionalFee: additionalFee ?? 50000.0,
      totalPrice: totalPrice ?? ((basePrice ?? 150000.0) + (additionalFee ?? 50000.0)),
      createdAt: now,
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
    String proofUrl, {
    String? paymentMethod,
    double? amount,
  }) async {
    return await remoteDataSource.submitPaymentProof(
      orderId,
      proofUrl,
      paymentMethod: paymentMethod,
      amount: amount,
    );
  }

  @override
  Future<PaymentEntity?> getPaymentByOrderId(String orderId) async {
    return await remoteDataSource.getPaymentByOrderId(orderId);
  }

  @override
  Future<OrderEntity> validatePayment(
    String orderId,
    bool isValid, {
    String? rejectionReason,
  }) async {
    return await remoteDataSource.validatePayment(
      orderId,
      isValid,
      rejectionReason: rejectionReason,
    );
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    return await remoteDataSource.getAllOrders();
  }
}
