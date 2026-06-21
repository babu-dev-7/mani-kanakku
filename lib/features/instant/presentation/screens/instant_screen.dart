import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../calculator/presentation/widgets/display_panel.dart';
import '../../../calculator/presentation/widgets/amount_card.dart';
import '../bloc/instant_bloc.dart';
import '../bloc/instant_state.dart';
import '../widgets/instant_keypad.dart';

/// Instant tab — ultra-simple live time-to-amount calculator.
///
/// Layout (top to bottom, no scrolling):
///   Display panel  (fixed responsive height)
///   Amount card    (fixed height)
///   Keypad         (Expanded — fills all remaining space)
class InstantScreen extends StatelessWidget {
  const InstantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Display panel ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: BlocBuilder<InstantBloc, InstantState>(
            buildWhen: (prev, curr) => prev.displayTime != curr.displayTime,
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return DisplayPanel(
                timeDisplay: state.displayTime,
                label: l10n.totalTime,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // ── Live amount card (hidden when amount calculation is OFF) ──
        BlocBuilder<InstantBloc, InstantState>(
          buildWhen: (prev, curr) =>
              prev.amount != curr.amount ||
              prev.isAmountCalculationEnabled != curr.isAmountCalculationEnabled,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: state.isAmountCalculationEnabled
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: AmountCard(
                          key: ValueKey(state.amount),
                          amount: state.amount,
                          label: l10n.amount,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
        // ── Keypad fills all remaining space ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: const InstantKeypad(),
          ),
        ),
      ],
    );
  }
}
