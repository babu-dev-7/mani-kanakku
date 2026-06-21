import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DisplayPanel extends StatelessWidget {
  final String timeDisplay;
  final String label;

  const DisplayPanel({
    super.key,
    required this.timeDisplay,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Stable fixed height — never resizes dynamically
    final panelHeight = (screenHeight * 0.20).clamp(130.0, 170.0);

    final parts = timeDisplay.split(':');
    // Always show HH:MM format (zero-pad hours to 2 digits)
    final hoursPart = (parts.isNotEmpty ? parts[0] : '0').padLeft(2, '0');
    final minutesPart = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';

    return Container(
      width: double.infinity,
      height: panelHeight,
      decoration: BoxDecoration(
        color: AppColors.darkDisplay,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkDisplay.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Time digits — FittedBox prevents overflow on very large numbers
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  hoursPart,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 80,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    color: AppColors.amber,
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                Text(
                  minutesPart,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 80,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
