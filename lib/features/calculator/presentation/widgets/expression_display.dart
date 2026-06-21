import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/calculator_bloc.dart';
import '../bloc/calculator_event.dart';
import '../bloc/calculator_state.dart';

/// Interactive expression row showing time chips and operators.
///
/// Chips are tappable (enter edit mode) and long-pressable (delete).
/// Operators between chips are tappable to toggle between + and −.
///
/// Scrolls horizontally, never wraps, always single line.
class ExpressionDisplay extends StatelessWidget {
  final List<ExpressionItem> expressionItems;
  final int? editingIndex;
  final String expression; // completed expression shown after "="
  final bool hasResult;

  const ExpressionDisplay({
    super.key,
    required this.expressionItems,
    required this.editingIndex,
    required this.expression,
    required this.hasResult,
  });

  @override
  Widget build(BuildContext context) {
    // After "=" — show the completed expression as rich text (non-interactive)
    if (hasResult && expression.isNotEmpty) {
      return _ResultRow(expression: expression);
    }

    // No items yet
    if (expressionItems.isEmpty) {
      return const SizedBox(height: 44);
    }

    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: false,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildChipRow(context),
        ),
      ),
    );
  }

  List<Widget> _buildChipRow(BuildContext context) {
    final bloc = context.read<CalculatorBloc>();
    final widgets = <Widget>[];

    for (int i = 0; i < expressionItems.length; i++) {
      final item = expressionItems[i];
      final isSelected = editingIndex == i;

      // Time chip
      widgets.add(_TimeChip(
        time: item.time,
        isSelected: isSelected,
        onTap: () => bloc.add(EditChipPressed(i)),
        onLongPress: () => _showChipOptions(context, bloc, i),
      ));

      // Operator after this chip (always shown — it's the pending operator)
      widgets.add(const SizedBox(width: 4));
      widgets.add(_OperatorToken(
        operator_: item.operator_,
        onTap: () => bloc.add(OperatorChangedForChip(i)),
      ));
      widgets.add(const SizedBox(width: 4));
    }

    return widgets;
  }

  void _showChipOptions(BuildContext context, CalculatorBloc bloc, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChipOptionsSheet(
        onEdit: () {
          Navigator.of(context).pop();
          bloc.add(EditChipPressed(index));
        },
        onDelete: () {
          Navigator.of(context).pop();
          bloc.add(DeleteChipPressed(index));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Completed result row (after "=")
// ─────────────────────────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final String expression;

  const _ResultRow({required this.expression});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: _buildRichText(expression),
        ),
      ),
    );
  }

  Widget _buildRichText(String expr) {
    final spans = <TextSpan>[];
    final tokens = expr.split(' ');
    bool afterEquals = false;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.isEmpty) continue;

      Color color;
      FontWeight weight = FontWeight.w500;

      if (token == '=') {
        afterEquals = true;
        color = AppColors.amber;
      } else if (afterEquals) {
        color = AppColors.primaryGreen;
        weight = FontWeight.w700;
      } else if (token == '+') {
        color = AppColors.primaryGreen;
      } else if (token == '-') {
        color = AppColors.errorRed;
      } else {
        color = AppColors.textPrimary;
      }

      spans.add(TextSpan(
        text: token,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: weight,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ));

      if (i < tokens.length - 1) {
        spans.add(const TextSpan(
          text: ' ',
          style: TextStyle(fontSize: 18),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      softWrap: false,
      overflow: TextOverflow.visible,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time chip widget
// ─────────────────────────────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TimeChip({
    required this.time,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.08)
              : AppColors.keypadDigit,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Operator token widget
// ─────────────────────────────────────────────────────────────────────────────

class _OperatorToken extends StatelessWidget {
  final String operator_;
  final VoidCallback onTap;

  const _OperatorToken({required this.operator_, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = operator_ == '+' ? AppColors.primaryGreen : AppColors.errorRed;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          operator_,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Long-press options bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ChipOptionsSheet extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChipOptionsSheet({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _SheetOption(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: AppColors.primaryGreen,
            onTap: onEdit,
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _SheetOption(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: AppColors.errorRed,
            onTap: onDelete,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
