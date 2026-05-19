import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 52,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 13,
        letterSpacing: 2,
        color: enabled ? AppColors.textPrimary : AppColors.textMuted,
      ),
    );

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Gradient layer (enabled)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: enabled ? 1.0 : 0.0,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            // Solid grey layer (disabled)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: enabled ? 0.0 : 1.0,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.knobCenter,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            // Label always on top
            Positioned.fill(
              child: Align(alignment: Alignment.center, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
