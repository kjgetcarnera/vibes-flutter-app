import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary,
            size: 11,
          ),
          const SizedBox(width: 5),
          Text(
            'YOUR WORDS ARE PRIVATE. ONLY VIBRATIONS ARE ANALYZED.',
            style: AppTextStyles.caption.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
