import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/calculator_bloc.dart';
import '../bloc/calculator_event.dart';
import '../bloc/calculator_state.dart';
import '../widgets/display_panel.dart';
import '../widgets/expression_display.dart';
import '../widgets/amount_card.dart';
import '../widgets/calculator_keypad.dart';

/// Calculator tab — professional time calculator with automatic history.
///
/// Layout (no scrolling, no save button):
///   Display panel     (fixed responsive height) — always shows live running total
///   Expression row    (44dp, horizontal scroll)  — interactive chips
///   Amount card       (fixed height)
///   Keypad            (Expanded — fills all remaining space)
///
/// History is saved automatically when '=' produces a valid result.
/// The BlocListener fires a brief SnackBar confirmation.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listenWhen: (previous, current) =>
          current.billSaved && !previous.billSaved,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Saved to history'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        children: [
          // ── Display panel (current input being typed; result after "=") ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: BlocBuilder<CalculatorBloc, CalculatorState>(
              buildWhen: (prev, curr) =>
                  prev.displayTime != curr.displayTime,
              builder: (context, state) {
                final l10n = AppLocalizations.of(context);
                return DisplayPanel(
                  timeDisplay: state.displayTime,
                  label: l10n.totalTime,
                );
              },
            ),
          ),
          // ── Expression row (interactive chips, horizontally scrollable) ──
          BlocBuilder<CalculatorBloc, CalculatorState>(
            buildWhen: (prev, curr) =>
                prev.expressionItems != curr.expressionItems ||
                prev.editingIndex != curr.editingIndex ||
                prev.expression != curr.expression ||
                prev.hasResult != curr.hasResult,
            builder: (context, state) {
              return ExpressionDisplay(
                expressionItems: state.expressionItems,
                editingIndex: state.editingIndex,
                expression: state.expression,
                hasResult: state.hasResult,
              );
            },
          ),
          // ── Edit mode banner ──
          BlocBuilder<CalculatorBloc, CalculatorState>(
            buildWhen: (prev, curr) =>
                prev.isEditingChip != curr.isEditingChip ||
                prev.editingIndex != curr.editingIndex,
            builder: (context, state) {
              if (!state.isEditingChip) return const SizedBox.shrink();
              return _EditModeBanner(
                index: state.editingIndex!,
                onCancel: () =>
                    context.read<CalculatorBloc>().add(const EditChipCancelled()),
                onConfirm: () =>
                    context.read<CalculatorBloc>().add(const EditChipConfirmed()),
              );
            },
          ),
          // ── Live amount card (hidden when amount calculation is OFF) ──
          BlocBuilder<CalculatorBloc, CalculatorState>(
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
                          duration: const Duration(milliseconds: 200),
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
          // ── Keypad — fills all remaining space ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: const CalculatorKeypad(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit mode banner — shown when a chip is being edited
// ─────────────────────────────────────────────────────────────────────────────

class _EditModeBanner extends StatelessWidget {
  final int index;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _EditModeBanner({
    required this.index,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.edit_outlined,
              size: 14,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 6),
            Text(
              'Editing entry ${index + 1}',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onConfirm,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
