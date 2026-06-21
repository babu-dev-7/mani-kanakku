class CurrencyUtils {
  CurrencyUtils._();

  static double calculateAmount(int totalMinutes, double rate) {
    if (totalMinutes <= 0 || rate <= 0) return 0.0;
    return (totalMinutes / 60.0) * rate;
  }

  static String formatIndianCurrency(double amount) {
    if (amount == 0) return '₹0.00';

    final isNegative = amount < 0;
    amount = amount.abs();

    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formatted = _formatIndianInteger(integerPart);
    final sign = isNegative ? '-' : '';
    return '$sign₹$formatted.$decimalPart';
  }

  static String _formatIndianInteger(String integerPart) {
    if (integerPart.length <= 3) return integerPart;

    final lastThree = integerPart.substring(integerPart.length - 3);
    var remaining = integerPart.substring(0, integerPart.length - 3);

    final groups = <String>[];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      groups.insert(0, remaining);
    }

    return '${groups.join(',')},$lastThree';
  }
}
