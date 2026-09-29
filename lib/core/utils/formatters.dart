import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _currencyFormatNoDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String currency(double amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return _currencyFormat.format(amount);
    }
    return _currencyFormatNoDecimals.format(amount);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String dateLong(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return 'Today';
    } else if (difference.inDays <= 1 ||
        (now.day - date.day == 1 && now.month == date.month)) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return dateShort(date);
    }
  }
}
