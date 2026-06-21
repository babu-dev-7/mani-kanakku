import 'package:equatable/equatable.dart';

abstract class InstantEvent extends Equatable {
  const InstantEvent();

  @override
  List<Object?> get props => [];
}

class InstantDigitPressed extends InstantEvent {
  final String digit;
  const InstantDigitPressed(this.digit);

  @override
  List<Object?> get props => [digit];
}

class InstantColonPressed extends InstantEvent {
  const InstantColonPressed();
}

class InstantClearPressed extends InstantEvent {
  const InstantClearPressed();
}

class InstantRateChanged extends InstantEvent {
  final double rate;
  const InstantRateChanged(this.rate);

  @override
  List<Object?> get props => [rate];
}

class InstantLoadInitialData extends InstantEvent {
  const InstantLoadInitialData();
}

class InstantToggleAmountCalculation extends InstantEvent {
  const InstantToggleAmountCalculation();
}
