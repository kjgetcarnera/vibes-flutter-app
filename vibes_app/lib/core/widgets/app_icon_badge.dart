import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.knobCenter,
        border: Border.all(color: AppColors.knobOuter, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(AppAssets.appIcon, fit: BoxFit.contain),
      ),
    );
  }
}
