import 'package:flutter/material.dart';

class KeypadButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  // When null the button expands to fill its parent (use inside Expanded rows).
  // Pass an explicit value (e.g. 64) for fixed-height contexts like the rate sheet.
  final double? height;

  const KeypadButton({
    super.key,
    this.text = '',
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.fontSize = 32,
    this.fontWeight = FontWeight.w500,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        splashColor: textColor.withValues(alpha: 0.1),
        highlightColor: textColor.withValues(alpha: 0.05),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: textColor,
                    size: 28,
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
