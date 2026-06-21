import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/bill_model.dart';
import '../../domain/calculator_repository.dart';
import 'calculator_event.dart';
import 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final CalculatorRepository repository;

  CalculatorBloc({required this.repository}) : super(const CalculatorState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<ToggleAmountCalculation>(_onToggleAmountCalculation);
    on<DigitPressed>(_onDigitPressed);
    on<ColonPressed>(_onColonPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<EqualsPressed>(_onEqualsPressed);
    on<ClearPressed>(_onClearPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<RateChanged>(_onRateChanged);
    on<EditChipPressed>(_onEditChipPressed);
    on<DeleteChipPressed>(_onDeleteChipPressed);
    on<OperatorChangedForChip>(_onOperatorChangedForChip);
    on<EditChipCancelled>(_onEditChipCancelled);
    on<EditChipConfirmed>(_onEditChipConfirmed);
  }

  // ─────────────────────────────────────────────
  // Helper: compute running total from items list
  // ─────────────────────────────────────────────

  static int computeRunningTotal(List<ExpressionItem> items) {
    if (items.isEmpty) return 0;
    int total = TimeUtils.parseTimeInput(items[0].time).totalMinutes;
    for (int i = 1; i < items.length; i++) {
      final minutes = TimeUtils.parseTimeInput(items[i].time).totalMinutes;
      if (items[i - 1].operator_ == '+') {
        total += minutes;
      } else {
        total -= minutes;
      }
    }
    return total < 0 ? 0 : total;
  }

  /// Returns calculated amount only when amount calculation is enabled.
  double _calcAmount(int minutes, {double? rate, bool? enabled}) {
    final isEnabled = enabled ?? state.isAmountCalculationEnabled;
    if (!isEnabled) return 0.0;
    final r = rate ?? state.rate;
    return CurrencyUtils.calculateAmount(minutes, r);
  }

  // ─────────────────────────────────────────────
  // Load initial
  // ─────────────────────────────────────────────

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<CalculatorState> emit,
  ) async {
    final rate = await repository.getRate();
    final amountEnabled = await repository.getAmountEnabled();
    emit(state.copyWith(rate: rate, isAmountCalculationEnabled: amountEnabled));
  }

  // ─────────────────────────────────────────────
  // Toggle amount calculation
  // ─────────────────────────────────────────────

  Future<void> _onToggleAmountCalculation(
    ToggleAmountCalculation event,
    Emitter<CalculatorState> emit,
  ) async {
    final newEnabled = !state.isAmountCalculationEnabled;
    await repository.saveAmountEnabled(newEnabled);

    // Recalculate displayed amount for current state
    double amount = 0.0;
    if (newEnabled) {
      if (state.hasResult) {
        amount = CurrencyUtils.calculateAmount(state.result.totalMinutes, state.rate);
      } else if (state.expressionItems.isNotEmpty) {
        final inputMinutes = state.inputBuffer.isNotEmpty
            ? TimeUtils.parseTimeInput(state.inputBuffer).totalMinutes
            : 0;
        amount = CurrencyUtils.calculateAmount(
            state.runningTotalMinutes + inputMinutes, state.rate);
      } else if (state.inputBuffer.isNotEmpty) {
        amount = CurrencyUtils.calculateAmount(
            TimeUtils.parseTimeInput(state.inputBuffer).totalMinutes, state.rate);
      }
    }

    emit(state.copyWith(
      isAmountCalculationEnabled: newEnabled,
      amount: amount,
    ));
  }

  // ─────────────────────────────────────────────
  // Digit pressed
  // ─────────────────────────────────────────────

  void _onDigitPressed(
    DigitPressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.hasResult) {
      emit(CalculatorState(
        rate: state.rate,
        isAmountCalculationEnabled: state.isAmountCalculationEnabled,
        inputBuffer: event.digit,
      ));
      return;
    }

    if (state.isEditingChip) {
      _applyDigitToEditingChip(event.digit, emit);
      return;
    }

    final newBuffer = state.inputBuffer + event.digit;
    final cleaned = newBuffer.replaceAll(':', '');
    if (cleaned.length > 4) return;

    final currentInput = TimeUtils.parseTimeInput(newBuffer);
    final liveMinutes = state.runningTotalMinutes + currentInput.totalMinutes;
    final liveAmount = _calcAmount(liveMinutes);

    emit(state.copyWith(
      inputBuffer: newBuffer,
      amount: liveAmount,
      hasResult: false,
      billSaved: false,
      clearError: true,
    ));
  }

  void _applyDigitToEditingChip(String digit, Emitter<CalculatorState> emit) {
    final idx = state.editingIndex!;
    final currentBuffer = state.inputBuffer + digit;
    final cleaned = currentBuffer.replaceAll(':', '');
    if (cleaned.length > 4) return;

    final updatedItems = List<ExpressionItem>.from(state.expressionItems);
    updatedItems[idx] = updatedItems[idx].copyWith(
      time: TimeUtils.formatRawInput(currentBuffer),
    );
    final newTotal = computeRunningTotal(updatedItems);

    emit(state.copyWith(
      inputBuffer: currentBuffer,
      expressionItems: updatedItems,
      runningTotalMinutes: newTotal,
      amount: _calcAmount(newTotal),
      clearError: true,
    ));
  }

  // ─────────────────────────────────────────────
  // Colon pressed
  // ─────────────────────────────────────────────

  void _onColonPressed(
    ColonPressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.inputBuffer.contains(':')) return;
    if (state.inputBuffer.isEmpty) return;

    final newBuffer = '${state.inputBuffer}:';

    if (state.isEditingChip) {
      final idx = state.editingIndex!;
      final updatedItems = List<ExpressionItem>.from(state.expressionItems);
      updatedItems[idx] = updatedItems[idx].copyWith(
        time: TimeUtils.formatRawInput(newBuffer),
      );
      final newTotal = computeRunningTotal(updatedItems);
      emit(state.copyWith(
        inputBuffer: newBuffer,
        expressionItems: updatedItems,
        runningTotalMinutes: newTotal,
        amount: _calcAmount(newTotal),
        clearError: true,
      ));
      return;
    }

    emit(state.copyWith(
      inputBuffer: newBuffer,
      clearError: true,
    ));
  }

  // ─────────────────────────────────────────────
  // Operator pressed
  // ─────────────────────────────────────────────

  void _onOperatorPressed(
    OperatorPressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.isEditingChip) {
      _confirmChipEdit(emit);
      return;
    }

    if (state.hasResult) {
      final resultTime = TimeUtils.formatTime(state.result);
      final items = [ExpressionItem(time: resultTime, operator_: event.operator_)];
      final total = computeRunningTotal(items);
      emit(CalculatorState(
        rate: state.rate,
        isAmountCalculationEnabled: state.isAmountCalculationEnabled,
        expressionItems: items,
        runningTotalMinutes: total,
        amount: _calcAmount(total),
        inputBuffer: '',
        billSaved: false,
      ));
      return;
    }

    if (state.inputBuffer.isEmpty && state.expressionItems.isEmpty) return;

    if (state.inputBuffer.isEmpty && state.expressionItems.isNotEmpty) {
      final items = List<ExpressionItem>.from(state.expressionItems);
      items[items.length - 1] = items.last.copyWith(operator_: event.operator_);
      final total = computeRunningTotal(items);
      emit(state.copyWith(
        expressionItems: items,
        runningTotalMinutes: total,
        amount: _calcAmount(total),
        billSaved: false,
      ));
      return;
    }

    final operand = TimeUtils.parseTimeInput(state.inputBuffer);
    final formattedOperand = TimeUtils.formatTime(operand);
    final newItem = ExpressionItem(time: formattedOperand, operator_: event.operator_);
    final updatedItems = [...state.expressionItems, newItem];
    final newTotal = computeRunningTotal(updatedItems);

    emit(state.copyWith(
      expressionItems: updatedItems,
      runningTotalMinutes: newTotal,
      inputBuffer: '',
      amount: _calcAmount(newTotal),
      hasResult: false,
      billSaved: false,
      clearError: true,
    ));
  }

  // ─────────────────────────────────────────────
  // Equals pressed — finalize and auto-save
  // ─────────────────────────────────────────────

  Future<void> _onEqualsPressed(
    EqualsPressed event,
    Emitter<CalculatorState> emit,
  ) async {
    if (state.isEditingChip) {
      _confirmChipEdit(emit);
      return;
    }

    if (state.expressionItems.isEmpty && state.inputBuffer.isEmpty) return;

    List<ExpressionItem> finalItems;
    if (state.inputBuffer.isNotEmpty) {
      final operand = TimeUtils.parseTimeInput(state.inputBuffer);
      final formattedOperand = TimeUtils.formatTime(operand);
      if (state.expressionItems.isNotEmpty) {
        finalItems = [...state.expressionItems, ExpressionItem(time: formattedOperand, operator_: '+')];
      } else {
        finalItems = [ExpressionItem(time: formattedOperand, operator_: '+')];
      }
    } else {
      finalItems = state.expressionItems;
    }

    final totalMinutes = computeRunningTotal(finalItems);
    final result = TimeValue.fromMinutes(totalMinutes);
    final formattedResult = TimeUtils.formatTime(result);

    final exprBuffer = StringBuffer();
    for (int i = 0; i < finalItems.length; i++) {
      exprBuffer.write(finalItems[i].time);
      if (i < finalItems.length - 1) {
        exprBuffer.write(' ${finalItems[i].operator_} ');
      }
    }
    final displayExpression = '${exprBuffer.toString()} = $formattedResult';

    final amount = state.isAmountCalculationEnabled
        ? CurrencyUtils.calculateAmount(result.totalMinutes, state.rate)
        : 0.0;

    // Auto-save: when amount OFF, save if result is non-zero (no billing info)
    //            when amount ON,  save if result is non-zero AND rate > 0
    final shouldSave = !result.isZero &&
        (state.isAmountCalculationEnabled ? state.rate > 0 : true);

    if (shouldSave) {
      final bill = BillModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        expression: displayExpression,
        finalTime: formattedResult,
        rate: state.isAmountCalculationEnabled ? state.rate : 0.0,
        amount: state.isAmountCalculationEnabled ? amount : 0.0,
      );
      await repository.addBill(bill);
    }

    emit(state.copyWith(
      result: result,
      expressionItems: const [],
      runningTotalMinutes: 0,
      expression: displayExpression,
      amount: amount,
      hasResult: true,
      inputBuffer: '',
      billSaved: shouldSave,
      clearEditingIndex: true,
      clearError: true,
    ));
  }

  // ─────────────────────────────────────────────
  // Clear
  // ─────────────────────────────────────────────

  void _onClearPressed(
    ClearPressed event,
    Emitter<CalculatorState> emit,
  ) {
    emit(CalculatorState(
      rate: state.rate,
      isAmountCalculationEnabled: state.isAmountCalculationEnabled,
    ));
  }

  // ─────────────────────────────────────────────
  // Backspace
  // ─────────────────────────────────────────────

  void _onBackspacePressed(
    BackspacePressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.hasResult) {
      emit(CalculatorState(
        rate: state.rate,
        isAmountCalculationEnabled: state.isAmountCalculationEnabled,
      ));
      return;
    }

    if (state.isEditingChip) {
      if (state.inputBuffer.isNotEmpty) {
        final newBuffer = state.inputBuffer.substring(0, state.inputBuffer.length - 1);
        final idx = state.editingIndex!;
        final updatedItems = List<ExpressionItem>.from(state.expressionItems);
        updatedItems[idx] = updatedItems[idx].copyWith(
          time: newBuffer.isNotEmpty ? TimeUtils.formatRawInput(newBuffer) : '0:00',
        );
        final newTotal = computeRunningTotal(updatedItems);
        emit(state.copyWith(
          inputBuffer: newBuffer,
          expressionItems: updatedItems,
          runningTotalMinutes: newTotal,
          amount: _calcAmount(newTotal),
          clearError: true,
        ));
      }
      return;
    }

    if (state.inputBuffer.isNotEmpty) {
      final newBuffer = state.inputBuffer.substring(0, state.inputBuffer.length - 1);
      final currentTime = TimeUtils.parseTimeInput(newBuffer);
      final liveMinutes = state.runningTotalMinutes + currentTime.totalMinutes;
      emit(state.copyWith(
        inputBuffer: newBuffer,
        amount: _calcAmount(liveMinutes),
        clearError: true,
      ));
    } else if (state.expressionItems.isNotEmpty) {
      final items = List<ExpressionItem>.from(state.expressionItems);
      final removed = items.removeLast();
      final newTotal = computeRunningTotal(items);
      emit(state.copyWith(
        expressionItems: items,
        runningTotalMinutes: newTotal,
        inputBuffer: removed.time,
        amount: _calcAmount(newTotal),
        clearError: true,
      ));
    }
  }

  // ─────────────────────────────────────────────
  // Rate changed
  // ─────────────────────────────────────────────

  Future<void> _onRateChanged(
    RateChanged event,
    Emitter<CalculatorState> emit,
  ) async {
    await repository.saveRate(event.rate);

    double amount = 0.0;
    if (state.isAmountCalculationEnabled) {
      if (state.hasResult) {
        amount = CurrencyUtils.calculateAmount(state.result.totalMinutes, event.rate);
      } else if (state.expressionItems.isNotEmpty) {
        amount = CurrencyUtils.calculateAmount(state.runningTotalMinutes, event.rate);
      }
    }

    emit(state.copyWith(rate: event.rate, amount: amount));
  }

  // ─────────────────────────────────────────────
  // Chip editing events
  // ─────────────────────────────────────────────

  void _onEditChipPressed(
    EditChipPressed event,
    Emitter<CalculatorState> emit,
  ) {
    final idx = event.index;
    if (idx < 0 || idx >= state.expressionItems.length) return;

    final chipTime = state.expressionItems[idx].time;
    final rawDigits = chipTime.replaceAll(':', '');

    emit(state.copyWith(
      editingIndex: idx,
      inputBuffer: rawDigits,
      billSaved: false,
    ));
  }

  void _onDeleteChipPressed(
    DeleteChipPressed event,
    Emitter<CalculatorState> emit,
  ) {
    final idx = event.index;
    if (idx < 0 || idx >= state.expressionItems.length) return;

    final items = List<ExpressionItem>.from(state.expressionItems);
    items.removeAt(idx);

    final newEditingIdx = state.editingIndex;
    bool clearEdit = newEditingIdx != null && newEditingIdx >= idx;

    final newTotal = computeRunningTotal(items);

    if (clearEdit) {
      emit(state.copyWith(
        expressionItems: items,
        runningTotalMinutes: newTotal,
        amount: _calcAmount(newTotal),
        inputBuffer: '',
        clearEditingIndex: true,
        billSaved: false,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
        expressionItems: items,
        runningTotalMinutes: newTotal,
        amount: _calcAmount(newTotal),
        billSaved: false,
        clearError: true,
      ));
    }
  }

  void _onOperatorChangedForChip(
    OperatorChangedForChip event,
    Emitter<CalculatorState> emit,
  ) {
    final idx = event.index;
    if (idx < 0 || idx >= state.expressionItems.length) return;

    final items = List<ExpressionItem>.from(state.expressionItems);
    final current = items[idx];
    final newOp = current.operator_ == '+' ? '-' : '+';
    items[idx] = current.copyWith(operator_: newOp);

    final newTotal = computeRunningTotal(items);
    emit(state.copyWith(
      expressionItems: items,
      runningTotalMinutes: newTotal,
      amount: _calcAmount(newTotal),
      billSaved: false,
    ));
  }

  void _onEditChipCancelled(
    EditChipCancelled event,
    Emitter<CalculatorState> emit,
  ) {
    if (!state.isEditingChip) return;
    emit(state.copyWith(
      inputBuffer: '',
      clearEditingIndex: true,
    ));
  }

  void _onEditChipConfirmed(
    EditChipConfirmed event,
    Emitter<CalculatorState> emit,
  ) {
    _confirmChipEdit(emit);
  }

  void _confirmChipEdit(Emitter<CalculatorState> emit) {
    if (!state.isEditingChip) return;
    final idx = state.editingIndex!;
    if (state.inputBuffer.isEmpty) {
      emit(state.copyWith(inputBuffer: '', clearEditingIndex: true));
      return;
    }
    final newTime = TimeUtils.formatTime(TimeUtils.parseTimeInput(state.inputBuffer));
    final items = List<ExpressionItem>.from(state.expressionItems);
    items[idx] = items[idx].copyWith(time: newTime);
    final newTotal = computeRunningTotal(items);
    emit(state.copyWith(
      expressionItems: items,
      runningTotalMinutes: newTotal,
      inputBuffer: '',
      amount: _calcAmount(newTotal),
      clearEditingIndex: true,
    ));
  }
}
