import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/localization/app_localizations.dart';
import 'keypad_button.dart';

class RateBottomSheet extends StatefulWidget {
  final double currentRate;
  final ValueChanged<double> onRateSaved;

  const RateBottomSheet({
    super.key,
    required this.currentRate,
    required this.onRateSaved,
  });

  @override
  State<RateBottomSheet> createState() => _RateBottomSheetState();
}

class _RateBottomSheetState extends State<RateBottomSheet> {
  String _inputBuffer = '';

  @override
  void initState() {
    super.initState();
    _inputBuffer = widget.currentRate.toInt().toString();
  }

  void _onDigit(String digit) {
    if (_inputBuffer.length >= 7) return;
    setState(() {
      if (_inputBuffer == '0') {
        _inputBuffer = digit;
      } else {
        _inputBuffer += digit;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_inputBuffer.isNotEmpty) {
        _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
      }
    });
  }

  void _onClear() {
    setState(() {
      _inputBuffer = '';
    });
  }

  void _onSave() {
    final rate = double.tryParse(_inputBuffer) ?? 0;
    if (rate > 0) {
      widget.onRateSaved(rate);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentValue = double.tryParse(_inputBuffer) ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.setRate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  CurrencyUtils.formatIndianCurrency(currentValue),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.perHour,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildKeypad(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: currentValue > 0 ? _onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.keypadDigit,
                disabledForegroundColor: AppColors.textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: KeypadButton(
              text: d,
              backgroundColor: AppColors.keypadDigit,
              textColor: AppColors.textPrimary,
              onPressed: () => _onDigit(d),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: KeypadButton(
              text: 'C',
              backgroundColor: AppColors.keypadClear,
              textColor: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              onPressed: _onClear,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: KeypadButton(
              text: '0',
              backgroundColor: AppColors.keypadDigit,
              textColor: AppColors.textPrimary,
              onPressed: () => _onDigit('0'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: KeypadButton(
              icon: Icons.backspace_outlined,
              backgroundColor: AppColors.amberLight,
              textColor: AppColors.amber,
              onPressed: _onBackspace,
            ),
          ),
        ),
      ],
    );
  }
}
