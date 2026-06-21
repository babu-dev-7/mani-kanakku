import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../calculator/domain/calculator_repository.dart';
import 'instant_event.dart';
import 'instant_state.dart';

class InstantBloc extends Bloc<InstantEvent, InstantState> {
  final CalculatorRepository repository;

  InstantBloc({required this.repository}) : super(const InstantState()) {
    on<InstantLoadInitialData>(_onLoadInitialData);
    on<InstantToggleAmountCalculation>(_onToggleAmountCalculation);
    on<InstantDigitPressed>(_onDigitPressed);
    on<InstantColonPressed>(_onColonPressed);
    on<InstantClearPressed>(_onClearPressed);
    on<InstantRateChanged>(_onRateChanged);
  }

  Future<void> _onLoadInitialData(
    InstantLoadInitialData event,
    Emitter<InstantState> emit,
  ) async {
    final rate = await repository.getRate();
    final amountEnabled = await repository.getAmountEnabled();
    final updated = state.copyWith(rate: rate, isAmountCalculationEnabled: amountEnabled);
    emit(updated.copyWith(amount: updated.liveAmount));
  }

  Future<void> _onToggleAmountCalculation(
    InstantToggleAmountCalculation event,
    Emitter<InstantState> emit,
  ) async {
    final newEnabled = !state.isAmountCalculationEnabled;
    final updated = state.copyWith(isAmountCalculationEnabled: newEnabled);
    emit(updated.copyWith(amount: updated.liveAmount));
  }

  void _onDigitPressed(
    InstantDigitPressed event,
    Emitter<InstantState> emit,
  ) {
    final newBuffer = state.inputBuffer + event.digit;
    // Strip colons for length check — allow max 4 raw digits (HH:MM)
    final cleaned = newBuffer.replaceAll(':', '');
    if (cleaned.length > 4) return;

    final updated = state.copyWith(inputBuffer: newBuffer);
    emit(updated.copyWith(amount: updated.liveAmount));
  }

  void _onColonPressed(
    InstantColonPressed event,
    Emitter<InstantState> emit,
  ) {
    // Only allow one colon and only after at least one digit
    if (state.inputBuffer.contains(':')) return;
    if (state.inputBuffer.isEmpty) return;

    emit(state.copyWith(inputBuffer: '${state.inputBuffer}:'));
  }

  void _onClearPressed(
    InstantClearPressed event,
    Emitter<InstantState> emit,
  ) {
    emit(InstantState(
      rate: state.rate,
      isAmountCalculationEnabled: state.isAmountCalculationEnabled,
    ));
  }

  Future<void> _onRateChanged(
    InstantRateChanged event,
    Emitter<InstantState> emit,
  ) async {
    await repository.saveRate(event.rate);
    final updated = state.copyWith(rate: event.rate);
    emit(updated.copyWith(amount: updated.liveAmount));
  }
}
