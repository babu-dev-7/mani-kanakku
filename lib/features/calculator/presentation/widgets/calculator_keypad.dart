import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/calculator_bloc.dart';
import '../bloc/calculator_event.dart';
import 'keypad_button.dart';

/// Calculator keypad with a wide number grid + slim operator rail.
///
/// Visual layout:
///
///   ┌───────────────┬──────┐
///   │   7   8   9   │  ⌫  │
///   │   4   5   6   │  +  │
///   │   1   2   3   │  -  │
///   │   C   0   :   │  =  │
///   └───────────────┴──────┘
///
/// Left area (flex 3)  — number buttons, wider and more touch-friendly
/// Right rail (flex 1) — operators, slimmer, vertically stacked
///
/// All rows use Expanded so the keypad fills exactly its parent's height.
class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CalculatorBloc>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left: 3×4 number grid (wider) ──
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(child: _numRow(['7', '8', '9'], bloc)),
              const SizedBox(height: 8),
              Expanded(child: _numRow(['4', '5', '6'], bloc)),
              const SizedBox(height: 8),
              Expanded(child: _numRow(['1', '2', '3'], bloc)),
              const SizedBox(height: 8),
              Expanded(child: _numRow(['C', '0', ':'], bloc)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // ── Right: operator rail (slimmer) ──
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _backspace(bloc)),
              const SizedBox(height: 8),
              Expanded(child: _operator('+', AppColors.primaryGreenLight, AppColors.primaryGreen, bloc)),
              const SizedBox(height: 8),
              Expanded(child: _operator('-', AppColors.errorRedLight, AppColors.errorRed, bloc)),
              const SizedBox(height: 8),
              Expanded(child: _equals(bloc)),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds one row of 3 number/function buttons.
  Widget _numRow(List<String> labels, CalculatorBloc bloc) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _numButton(label, bloc),
          ),
        );
      }).toList(),
    );
  }

  /// Resolves a label to the correct number/function button.
  Widget _numButton(String label, CalculatorBloc bloc) {
    switch (label) {
      case 'C':
        return KeypadButton(
          text: 'C',
          backgroundColor: AppColors.keypadClear,
          textColor: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          height: null,
          onPressed: () => bloc.add(const ClearPressed()),
        );
      case ':':
        return KeypadButton(
          text: ':',
          backgroundColor: AppColors.keypadDigit,
          textColor: AppColors.textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: null,
          onPressed: () => bloc.add(const ColonPressed()),
        );
      default:
        return KeypadButton(
          text: label,
          backgroundColor: AppColors.keypadDigit,
          textColor: AppColors.textPrimary,
          height: null,
          onPressed: () => bloc.add(DigitPressed(label)),
        );
    }
  }

  Widget _backspace(CalculatorBloc bloc) {
    return KeypadButton(
      icon: Icons.backspace_outlined,
      backgroundColor: AppColors.amberLight,
      textColor: AppColors.amber,
      height: null,
      onPressed: () => bloc.add(const BackspacePressed()),
    );
  }

  Widget _operator(
    String op,
    Color bgColor,
    Color fgColor,
    CalculatorBloc bloc,
  ) {
    return KeypadButton(
      text: op,
      backgroundColor: bgColor,
      textColor: fgColor,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: null,
      onPressed: () => bloc.add(OperatorPressed(op)),
    );
  }

  Widget _equals(CalculatorBloc bloc) {
    return KeypadButton(
      text: '=',
      backgroundColor: AppColors.primaryGreen,
      textColor: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: null,
      onPressed: () => bloc.add(const EqualsPressed()),
    );
  }
}
