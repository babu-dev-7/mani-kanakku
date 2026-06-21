import 'package:equatable/equatable.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object?> get props => [];
}

class DigitPressed extends CalculatorEvent {
  final String digit;
  const DigitPressed(this.digit);

  @override
  List<Object?> get props => [digit];
}

class ColonPressed extends CalculatorEvent {
  const ColonPressed();
}

class OperatorPressed extends CalculatorEvent {
  final String operator_;
  const OperatorPressed(this.operator_);

  @override
  List<Object?> get props => [operator_];
}

class EqualsPressed extends CalculatorEvent {
  const EqualsPressed();
}

class ClearPressed extends CalculatorEvent {
  const ClearPressed();
}

class BackspacePressed extends CalculatorEvent {
  const BackspacePressed();
}

class RateChanged extends CalculatorEvent {
  final double rate;
  const RateChanged(this.rate);

  @override
  List<Object?> get props => [rate];
}

class LoadInitialData extends CalculatorEvent {
  const LoadInitialData();
}

/// Enter edit mode for the chip at [index].
class EditChipPressed extends CalculatorEvent {
  final int index;
  const EditChipPressed(this.index);

  @override
  List<Object?> get props => [index];
}

/// Delete the chip at [index] from the expression.
class DeleteChipPressed extends CalculatorEvent {
  final int index;
  const DeleteChipPressed(this.index);

  @override
  List<Object?> get props => [index];
}

/// Toggle the operator on chip at [index] between '+' and '-'.
class OperatorChangedForChip extends CalculatorEvent {
  final int index;
  const OperatorChangedForChip(this.index);

  @override
  List<Object?> get props => [index];
}

/// Exit edit mode without saving (cancel edit).
class EditChipCancelled extends CalculatorEvent {
  const EditChipCancelled();
}

/// Confirm the current inputBuffer as the new value for the chip being edited.
class EditChipConfirmed extends CalculatorEvent {
  const EditChipConfirmed();
}

/// Toggle amount calculation on or off.
class ToggleAmountCalculation extends CalculatorEvent {
  const ToggleAmountCalculation();
}
