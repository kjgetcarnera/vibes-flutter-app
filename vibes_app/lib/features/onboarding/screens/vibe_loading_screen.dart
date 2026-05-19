import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // TODO: replace mock with real result once API is live
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
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => CustomPaint(
                  painter: _FrequencyRingPainter(_controller.value),
                ),
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

class _FrequencyRingPainter extends CustomPainter {
  _FrequencyRingPainter(this.t);

  final double t;

  static const int _barCount = 60;
  static const double _innerRadius = 55;
  static const double _maxBarLength = 45;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < _barCount; i++) {
      final angle = (i / _barCount) * 2 * math.pi - math.pi / 2;

      // Wave: combine two sine waves for organic feel
      final wave = (math.sin((i / _barCount) * 4 * math.pi + t * 2 * math.pi) * 0.5 +
              math.sin((i / _barCount) * 7 * math.pi + t * 2 * math.pi * 1.3) * 0.5)
          .abs();
      final barLength = 6 + wave * _maxBarLength;

      final x1 = center.dx + math.cos(angle) * _innerRadius;
      final y1 = center.dy + math.sin(angle) * _innerRadius;
      final x2 = center.dx + math.cos(angle) * (_innerRadius + barLength);
      final y2 = center.dy + math.sin(angle) * (_innerRadius + barLength);

      // Gradient from cyan to green based on wave amplitude
      final lerpValue = wave.clamp(0.0, 1.0);
      final color = Color.lerp(AppColors.accentCyan, AppColors.accentGreen, lerpValue)!;

      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_FrequencyRingPainter old) => old.t != t;
}
