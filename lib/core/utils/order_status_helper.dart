import 'package:flutter/material.dart';

import '../../features/booking/domain/entities/order_entity.dart';
import '../../features/booking/domain/entities/payment_entity.dart';
import '../widgets/status_badge.dart';

class OrderStatusHelper {
  OrderStatusHelper._();

  static String getPaymentStatusText(OrderEntity order, PaymentEntity? payment) {
    if (payment != null) {
      if (payment.paymentStatus == 'valid') return 'Pembayaran Valid';
      if (payment.paymentStatus == 'ditolak') return 'Pembayaran Ditolak';
      if (payment.paymentStatus == 'menungguValidasi') return 'Menunggu Validasi';
    }
    switch (order.status) {
      case OrderStatus.menungguPembayaran:
        return 'Menunggu Pembayaran';
      case OrderStatus.menungguValidasi:
        return 'Menunggu Validasi';
      case OrderStatus.menujuLokasi:
      case OrderStatus.tibaDiLokasi:
      case OrderStatus.dalamPerjalanan:
      case OrderStatus.layananSelesai:
        return 'Pembayaran Valid';
    }
  }

  static StatusBadge getPaymentBadge(OrderEntity order, PaymentEntity? payment) {
    final text = getPaymentStatusText(order, payment);
    if (text == 'Pembayaran Valid') {
      return StatusBadge.success(text, icon: Icons.verified_rounded);
    } else if (text == 'Menunggu Validasi') {
      return StatusBadge.warning(text, icon: Icons.hourglass_top_rounded);
    } else if (text == 'Pembayaran Ditolak') {
      return StatusBadge.error(text, icon: Icons.cancel_rounded);
    } else {
      return StatusBadge.error(text, icon: Icons.payment_rounded);
    }
  }

  static String getServiceStatusText(OrderEntity order, PaymentEntity? payment) {
    switch (order.status) {
      case OrderStatus.menungguPembayaran:
      case OrderStatus.menungguValidasi:
        return 'Menunggu Konfirmasi';
      case OrderStatus.menujuLokasi:
        return 'Menuju Lokasi Penjemputan';
      case OrderStatus.tibaDiLokasi:
        return 'Pasien Dijemput';
      case OrderStatus.dalamPerjalanan:
        return 'Menuju Rumah Sakit';
      case OrderStatus.layananSelesai:
        return 'Layanan Selesai';
    }
  }

  static StatusBadge getServiceBadge(OrderEntity order, PaymentEntity? payment) {
    final text = getServiceStatusText(order, payment);
    switch (order.status) {
      case OrderStatus.layananSelesai:
        return StatusBadge.success(text, icon: Icons.check_circle_rounded);
      case OrderStatus.dalamPerjalanan:
        return StatusBadge.info(text, icon: Icons.local_hospital_rounded);
      case OrderStatus.tibaDiLokasi:
        return StatusBadge.info(text, icon: Icons.airline_seat_recline_normal_rounded);
      case OrderStatus.menujuLokasi:
        return StatusBadge.warning(text, icon: Icons.navigation_rounded);
      case OrderStatus.menungguValidasi:
      case OrderStatus.menungguPembayaran:
        return StatusBadge.warning(text, icon: Icons.schedule_rounded);
    }
  }

  static bool isOrderActive(OrderEntity order) {
    return order.status != OrderStatus.layananSelesai;
  }

  static bool isOrderFinished(OrderEntity order) {
    return order.status == OrderStatus.layananSelesai;
  }
}
