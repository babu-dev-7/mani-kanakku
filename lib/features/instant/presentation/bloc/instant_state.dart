import 'package:equatable/equatable.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/utils/currency_utils.dart';

class InstantState extends Equatable {
  final String inputBuffer;
  final double rate;
  final double amount;
  final bool isAmountCalculationEnabled;

  const InstantState({
    this.inputBuffer = '',
    this.rate = 1500.0,
    this.amount = 0.0,
    this.isAmountCalculationEnabled = true,
  });

  String get displayTime {
    if (inputBuffer.isEmpty) {
      return '00:00';
    }
    return TimeUtils.formatRawInput(inputBuffer);
  }

  TimeValue get currentTime {
    if (inputBuffer.isEmpty) return const TimeValue.zero();
    return TimeUtils.parseTimeInput(inputBuffer);
  }

  double get liveAmount {
    if (!isAmountCalculationEnabled) return 0.0;
    final time = currentTime;
    if (time.isZero || rate <= 0) return 0.0;
    return CurrencyUtils.calculateAmount(time.totalMinutes, rate);
  }

  InstantState copyWith({
    String? inputBuffer,
    double? rate,
    double? amount,
    bool? isAmountCalculationEnabled,
  }) {
    return InstantState(
      inputBuffer: inputBuffer ?? this.inputBuffer,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      isAmountCalculationEnabled:
          isAmountCalculationEnabled ?? this.isAmountCalculationEnabled,
    );
  }

  @override
  List<Object?> get props => [inputBuffer, rate, amount, isAmountCalculationEnabled];
}
