import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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
      style: const TextStyle(
        fontFamily: 'Kamerik105',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.36,
        height: 24 / 18,
      ).copyWith(color: enabled ? AppColors.background : AppColors.textMuted),
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
                  borderRadius: BorderRadius.circular(30),
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
                  borderRadius: BorderRadius.circular(30),
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
