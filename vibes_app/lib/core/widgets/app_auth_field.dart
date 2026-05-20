import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppAuthField extends StatelessWidget {
  const AppAuthField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.error,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? error;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.knobCenter,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? Colors.redAccent.withAlpha(180)
                  : AppColors.knobOuter,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(prefixIcon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  textInputAction: textInputAction,
                  inputFormatters: inputFormatters,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: AppTextStyles.kamerikInput.copyWith(
                    color: const Color(0xFFFFFEFE),
                  ),
                  cursorColor: AppColors.accentCyan,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.kamerikInput,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (suffix != null) ...[suffix!, const SizedBox(width: 14)],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              error!,
              style: AppTextStyles.caption.copyWith(
                color: Colors.redAccent,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
