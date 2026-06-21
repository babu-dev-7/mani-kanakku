import 'package:flutter_test/flutter_test.dart';
import 'package:mani_kannaku/core/utils/time_utils.dart';
import 'package:mani_kannaku/core/utils/currency_utils.dart';

void main() {
  group('TimeUtils', () {
    test('parseTimeInput parses 105 as 1:05', () {
      final result = TimeUtils.parseTimeInput('105');
      expect(result.hours, 1);
      expect(result.minutes, 5);
      expect(result.totalMinutes, 65);
    });

    test('parseTimeInput parses 205 as 2:05', () {
      final result = TimeUtils.parseTimeInput('205');
      expect(result.hours, 2);
      expect(result.minutes, 5);
      expect(result.totalMinutes, 125);
    });

    test('parseTimeInput parses 5 as 0:05', () {
      final result = TimeUtils.parseTimeInput('5');
      expect(result.hours, 0);
      expect(result.minutes, 5);
      expect(result.totalMinutes, 5);
    });

    test('parseTimeInput parses 530 as 5:30', () {
      final result = TimeUtils.parseTimeInput('530');
      expect(result.hours, 5);
      expect(result.minutes, 30);
      expect(result.totalMinutes, 330);
    });

    test('addTime adds correctly', () {
      final a = TimeUtils.parseTimeInput('105');
      final b = TimeUtils.parseTimeInput('205');
      final result = TimeUtils.addTime(a, b);
      expect(result.hours, 3);
      expect(result.minutes, 10);
      expect(TimeUtils.formatTime(result), '3:10');
    });

    test('subtractTime subtracts correctly', () {
      final a = TimeUtils.parseTimeInput('530');
      final b = TimeUtils.parseTimeInput('125');
      final result = TimeUtils.subtractTime(a, b);
      expect(result.hours, 4);
      expect(result.minutes, 5);
      expect(TimeUtils.formatTime(result), '4:05');
    });

    test('subtractTime clamps to zero', () {
      final a = TimeUtils.parseTimeInput('100');
      final b = TimeUtils.parseTimeInput('200');
      final result = TimeUtils.subtractTime(a, b);
      expect(result.hours, 0);
      expect(result.minutes, 0);
    });

    test('formatRawInput formats correctly', () {
      expect(TimeUtils.formatRawInput('105'), '1:05');
      expect(TimeUtils.formatRawInput('30'), '0:30');
      expect(TimeUtils.formatRawInput('1230'), '12:30');
      expect(TimeUtils.formatRawInput('5'), '0:05');
      expect(TimeUtils.formatRawInput('12'), '0:12');
    });
  });

  group('CurrencyUtils', () {
    test('calculateAmount computes correctly for calculator mode', () {
      // 3:10 = 190 minutes at ₹1500/hr
      final amount = CurrencyUtils.calculateAmount(190, 1500);
      expect(amount, closeTo(4750.0, 0.01));
    });

    test('calculateAmount computes correctly for instant mode', () {
      // 00:05 = 5 minutes at ₹1000/hr
      final amount = CurrencyUtils.calculateAmount(5, 1000);
      expect(amount, closeTo(83.33, 0.01));
    });

    test('calculateAmount handles 1 hour exactly', () {
      // 01:00 = 60 minutes at ₹1500/hr
      final amount = CurrencyUtils.calculateAmount(60, 1500);
      expect(amount, closeTo(1500.0, 0.01));
    });

    test('calculateAmount returns 0 for zero time', () {
      final amount = CurrencyUtils.calculateAmount(0, 1500);
      expect(amount, 0.0);
    });

    test('formatIndianCurrency formats correctly', () {
      expect(CurrencyUtils.formatIndianCurrency(4750), '₹4,750.00');
      expect(CurrencyUtils.formatIndianCurrency(150000), '₹1,50,000.00');
      expect(CurrencyUtils.formatIndianCurrency(0), '₹0.00');
      expect(CurrencyUtils.formatIndianCurrency(83.33), '₹83.33');
    });
  });
}
