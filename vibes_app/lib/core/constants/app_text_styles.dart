import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.spaceMono(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static TextStyle get displayMedium => GoogleFonts.spaceMono(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
    letterSpacing: -0.2,
  );

  static TextStyle get headingBold => GoogleFonts.spaceMono(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle get bodyMono => GoogleFonts.spaceMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.spaceMono(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  static TextStyle get labelSmall => GoogleFonts.spaceMono(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  // ── Kamerik 105 ──────────────────────────────────────────────
  static const TextStyle kamerikToggle = TextStyle(
    fontFamily: 'Kamerik105',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0xFFFFFEFE),
    height: 24 / 18,
    letterSpacing: -0.36,
  );

  static TextStyle get kamerikInput => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0x80FFFEFE),
    height: 19 / 14,
    letterSpacing: -0.15,
  );

  static TextStyle get talkLabel => GoogleFonts.spaceMono(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.accentCyan,
    letterSpacing: 1.5,
  );
}
