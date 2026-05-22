import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/splash_screen.dart';

class VibesApp extends StatelessWidget {
  const VibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MANTRA-0.85',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentCyan,
          secondary: AppColors.accentGreen,
          surface: AppColors.surfacePanel,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
