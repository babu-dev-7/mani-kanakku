import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../calculator/presentation/widgets/keypad_button.dart';
import '../bloc/instant_bloc.dart';
import '../bloc/instant_event.dart';

/// Perfectly symmetric 3×4 keypad for the Instant tab.
///
/// Layout:
///   7   8   9
///   4   5   6
///   1   2   3
///   C   0   :
///
/// All buttons are equal size. No operators, no backspace.
/// Height is fully flexible — buttons expand to fill their Expanded parent.
class InstantKeypad extends StatelessWidget {
  const InstantKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<InstantBloc>();

    return Column(
      children: [
        Expanded(
          child: _buildRow([
            _digit('7', bloc),
            _digit('8', bloc),
            _digit('9', bloc),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildRow([
            _digit('4', bloc),
            _digit('5', bloc),
            _digit('6', bloc),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildRow([
            _digit('1', bloc),
            _digit('2', bloc),
            _digit('3', bloc),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildRow([
            _clear(bloc),
            _digit('0', bloc),
            _colon(bloc),
          ]),
        ),
      ],
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Row(
      children: buttons.map((btn) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: btn,
          ),
        );
      }).toList(),
    );
  }

  Widget _digit(String digit, InstantBloc bloc) {
    return KeypadButton(
      text: digit,
      backgroundColor: AppColors.keypadDigit,
      textColor: AppColors.textPrimary,
      height: null, // expand to fill Expanded parent
      onPressed: () => bloc.add(InstantDigitPressed(digit)),
    );
  }

  Widget _clear(InstantBloc bloc) {
    return KeypadButton(
      text: 'C',
      backgroundColor: AppColors.keypadClear,
      textColor: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      height: null,
      onPressed: () => bloc.add(const InstantClearPressed()),
    );
  }

  Widget _colon(InstantBloc bloc) {
    return KeypadButton(
      text: ':',
      backgroundColor: AppColors.keypadDigit,
      textColor: AppColors.textPrimary,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: null,
      onPressed: () => bloc.add(const InstantColonPressed()),
    );
  }
}
