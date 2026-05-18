import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF15171B);
  static const Color surfaceDark = Color(0xFF141414);
  static const Color surfacePanel = Color(0xFF0D0F12);

  // Knob / UI elements
  static const Color knobOuter = Color(0xFF3A3A3C);
  static const Color knobMid = Color(0xFF48484A);
  static const Color knobInner = Color(0xFF8E8E93);
  static const Color knobCenter = Color(0xFF2C2C2E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF48484A);

  // Accent gradient: cyan → green
  static const Color accentCyan = Color(0xFF04EFF5);
  static const Color accentGreen = Color(0xFF11E560);

  // Secondary accent gradient
  static const Color accentGreen2 = Color(0xFF2FE17A);
  static const Color accentCyan2 = Color(0xFF00FFF7);

  // Indicators
  static const Color indicatorActive = accentCyan;
  static const Color indicatorInactive = Color(0xFF3A3A3C);

  // Overlay
  static const Color overlayBlack60 = Color(0x99000000);
  static const Color overlayBlack20 = Color(0x33000000);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient2 = LinearGradient(
    colors: [accentGreen2, accentCyan2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient knobShimmer = LinearGradient(
    colors: [Color(0xFF1D1D1D), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient panelGradient = LinearGradient(
    colors: [Color(0x26666666), Color(0xFF141414)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
