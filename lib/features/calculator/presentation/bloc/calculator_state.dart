import 'package:equatable/equatable.dart';
import '../../../../core/utils/time_utils.dart';

/// A single item in the expression list.
///
/// [time]      — formatted time string, e.g. "5:55"
/// [operator_] — the operator that follows this item, e.g. "+" or "-"
///               The last item's operator is the pending operator waiting for next input.
class ExpressionItem extends Equatable {
  final String time;
  final String operator_;

  const ExpressionItem({required this.time, required this.operator_});

  ExpressionItem copyWith({String? time, String? operator_}) {
    return ExpressionItem(
      time: time ?? this.time,
      operator_: operator_ ?? this.operator_,
    );
  }

  @override
  List<Object?> get props => [time, operator_];
}

class CalculatorState extends Equatable {
  final String inputBuffer;
  final TimeValue result;
  /// Structured list of confirmed expression items.
  final List<ExpressionItem> expressionItems;
  /// Pre-computed running total in minutes (from expressionItems only, not inputBuffer).
  final int runningTotalMinutes;
  /// Index of the chip currently being edited, or null for normal input mode.
  final int? editingIndex;
  /// The completed display expression shown after "=" e.g. "5:55 + 6:44 = 12:39"
  final String expression;
  final double rate;
  final double amount;
  final bool hasResult;
  final bool billSaved;
  final String? errorMessage;
  final bool isAmountCalculationEnabled;

  const CalculatorState({
    this.inputBuffer = '',
    this.result = const TimeValue.zero(),
    this.expressionItems = const [],
    this.runningTotalMinutes = 0,
    this.editingIndex,
    this.expression = '',
    this.rate = 1500.0,
    this.amount = 0.0,
    this.hasResult = false,
    this.billSaved = false,
    this.errorMessage,
    this.isAmountCalculationEnabled = true,
  });

  bool get isEditingChip => editingIndex != null;

  /// The value shown in the big display.
  ///
  /// Priority:
  ///   1. Final result (after =)
  ///   2. Current typed input (always visible while typing, even mid-expression)
  ///   3. "0:00" (placeholder, e.g. right after an operator is pressed)
  ///
  /// The running total is still tracked internally in [runningTotalMinutes]
  /// and drives the amount calculation — only the display behavior differs.
  String get displayTime {
    if (hasResult) {
      return TimeUtils.formatTime(result);
    }
    if (inputBuffer.isNotEmpty) {
      return TimeUtils.formatRawInput(inputBuffer);
    }
    return '0:00';
  }

  CalculatorState copyWith({
    String? inputBuffer,
    TimeValue? result,
    List<ExpressionItem>? expressionItems,
    int? runningTotalMinutes,
    int? editingIndex,
    String? expression,
    double? rate,
    double? amount,
    bool? hasResult,
    bool? billSaved,
    String? errorMessage,
    bool? isAmountCalculationEnabled,
    bool clearEditingIndex = false,
    bool clearError = false,
  }) {
    return CalculatorState(
      inputBuffer: inputBuffer ?? this.inputBuffer,
      result: result ?? this.result,
      expressionItems: expressionItems ?? this.expressionItems,
      runningTotalMinutes: runningTotalMinutes ?? this.runningTotalMinutes,
      editingIndex:
          clearEditingIndex ? null : (editingIndex ?? this.editingIndex),
      expression: expression ?? this.expression,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      hasResult: hasResult ?? this.hasResult,
      billSaved: billSaved ?? this.billSaved,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      isAmountCalculationEnabled:
          isAmountCalculationEnabled ?? this.isAmountCalculationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        inputBuffer,
        result,
        expressionItems,
        runningTotalMinutes,
        editingIndex,
        expression,
        rate,
        amount,
        hasResult,
        billSaved,
        errorMessage,
        isAmountCalculationEnabled,
      ];
}
