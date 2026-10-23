import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatFull(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'id_ID').format(dateTime);
  }

  static String formatCurrency(double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }
}
