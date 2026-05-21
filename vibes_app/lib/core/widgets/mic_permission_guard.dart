import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Shows a bottom sheet when microphone permission is denied.
/// - [onGranted] is called once permission is confirmed.
/// - [onDismiss] is called if the user dismisses without granting (e.g. goes back).
///
/// Usage: call [MicPermissionGuard.check] instead of
/// [Permission.microphone.request()] directly.
class MicPermissionGuard {
  MicPermissionGuard._();

  /// Checks mic permission and resolves to [true] if granted.
  /// If denied, shows a bottom sheet allowing the user to retry or open settings.
  /// If permanently denied, only offers the "Open Settings" option.
  static Future<bool> check(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isGranted) return true;

    // First-time or soft-denied: request directly first.
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) return true;
    }

    // Still not granted — show bottom sheet.
    if (!context.mounted) return false;
    final granted = await _showDeniedSheet(context, isPermanent: status.isPermanentlyDenied);
    return granted;
  }

  static Future<bool> _showDeniedSheet(
    BuildContext context, {
    required bool isPermanent,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MicPermissionSheet(isPermanent: isPermanent),
    );
    return result ?? false;
  }
}

class _MicPermissionSheet extends StatelessWidget {
  const _MicPermissionSheet({required this.isPermanent});

  final bool isPermanent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.knobCenter,
              border: Border.all(color: AppColors.knobOuter, width: 1),
            ),
            child: const Icon(
              Icons.mic_off_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Microphone access required',
            style: AppTextStyles.headingBold,
          ),
          const SizedBox(height: 8),
          Text(
            isPermanent
                ? 'Microphone permission was permanently denied. Please enable it in Settings to continue.'
                : 'Vibes needs your microphone to analyse your voice. Please allow access to continue.',
            style: AppTextStyles.bodyMono,
          ),
          const SizedBox(height: 28),

          if (isPermanent) ...[
            _SheetButton(
              label: 'Open Settings',
              primary: true,
              onTap: () async {
                await openAppSettings();
                if (context.mounted) Navigator.of(context).pop(false);
              },
            ),
          ] else ...[
            _SheetButton(
              label: 'Allow Microphone',
              primary: true,
              onTap: () async {
                final status = await Permission.microphone.request();
                if (context.mounted) Navigator.of(context).pop(status.isGranted);
              },
            ),
          ],
          const SizedBox(height: 12),
          _SheetButton(
            label: 'Go Back',
            primary: false,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: primary ? AppColors.accentGradient : null,
          color: primary ? null : AppColors.knobCenter,
          borderRadius: BorderRadius.circular(14),
          border: primary
              ? null
              : Border.all(color: AppColors.knobOuter, width: 1),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMono.copyWith(
            color: primary ? Colors.black : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
