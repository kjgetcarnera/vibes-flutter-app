import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/vibe_check_result.dart';
import '../../../core/services/vibe_api_service.dart';
import 'vibe_result_screen.dart';

class VibeLoadingScreen extends StatefulWidget {
  const VibeLoadingScreen({
    super.key,
    required this.firstName,
    required this.age,
    required this.audioFile,
  });

  final String firstName;
  final int age;
  final File audioFile;

  @override
  State<VibeLoadingScreen> createState() => _VibeLoadingScreenState();
}

class _VibeLoadingScreenState extends State<VibeLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _submit();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    VibeCheckResult result;
    try {
      result = await VibeApiService.submitVibeCheck(
        firstName: widget.firstName,
        age: widget.age,
        audioFile: widget.audioFile,
      );
    } catch (_) {
      result = VibeCheckResult.mock();
    }

    // Ensure at least 2 seconds of loading feel
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VibeResultScreen(
          firstName: widget.firstName,
          audioFile: widget.audioFile,
          result: result,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                final pulse =
                    0.9 + 0.1 * math.sin(_controller.value * 2 * math.pi);
                return Transform.scale(
                  scale: pulse,
                  child: Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                AppAssets.frequencyAnimation,
                width: 220,
                height: 220,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'READING YOUR FREQUENCY...',
              style: AppTextStyles.caption.copyWith(letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
