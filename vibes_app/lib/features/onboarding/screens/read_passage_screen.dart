// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_icon_badge.dart';
import 'vibe_loading_screen.dart';

const _passage =
    'My voice shows my brain.\nMy brain responds to sound.\nSound changes my state.\n\n'
    'I can measure it. I can restore it.\nI can prove it changed. This is how I\n'
    'take care of my brain. And where\never I am today -- I am enough.';

class ReadPassageScreen extends StatefulWidget {
  const ReadPassageScreen({
    super.key,
    required this.firstName,
    required this.age,
  });

  final String firstName;
  final int age;

  @override
  State<ReadPassageScreen> createState() => _ReadPassageScreenState();
}

class _ReadPassageScreenState extends State<ReadPassageScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _waveController;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _startRecording();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _waveController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!mounted || !status.isGranted) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/vibe_check_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }
    if (mounted) setState(() => _isPaused = !_isPaused);
  }

  Future<void> _stopAndSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final path = await _recorder.stop();
    setState(() => _isRecording = false);

    if (path == null) {
      _showError('Recording failed. Please try again.');
      setState(() => _isSubmitting = false);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VibeLoadingScreen(
          firstName: widget.firstName,
          age: widget.age,
          audioFile: File(path),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _cancel() async {
    await _recorder.stop();
    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyMono),
        backgroundColor: AppColors.surfacePanel,
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

    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;
    final bottomBarH = screenH * 0.30;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Scrollable passage ──
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPad + 72,
                  left: 24,
                  right: 24,
                  bottom: bottomBarH + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READ THIS PASSAGE OUTLOUD',
                      style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(_passage, style: AppTextStyles.displayMedium),
                  ],
                ),
              ),
            ),
          ),

          // ── Sticky top nav bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: topPad + 8,
                left: 20,
                right: 20,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withAlpha(15),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _cancel,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.knobCenter,
                        border: Border.all(
                          color: AppColors.knobOuter,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                  const AppIconBadge(),
                ],
              ),
            ),
          ),

          // ── Sticky bottom record bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomBarH,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: Colors.white.withAlpha(15), width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── Controls row ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: _isSubmitting
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentCyan,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording && !_isPaused
                                      ? const Color(0xFFFF2D87)
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _isRecording
                                      ? (_isPaused ? 'Paused' : 'Recording...')
                                      : 'Starting mic...',
                                  style: AppTextStyles.bodyMono,
                                ),
                              ),
                              GestureDetector(
                                onTap: _isRecording ? _togglePause : null,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.knobCenter,
                                    border: Border.all(
                                      color: AppColors.knobOuter,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _isPaused ? Icons.play_arrow : Icons.pause,
                                    color: _isRecording
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _isRecording ? _stopAndSubmit : null,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _isRecording
                                        ? AppColors.accentGradient
                                        : null,
                                    color: _isRecording
                                        ? null
                                        : AppColors.knobCenter,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: _isRecording
                                        ? Colors.black
                                        : AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  // ── Voice wave animation ──
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (_, __) => CustomPaint(
                          painter: _VoiceWavePainter(
                            progress: _waveController.value,
                            active: _isRecording && !_isPaused,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceWavePainter extends CustomPainter {
  _VoiceWavePainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  static const int _barCount = 40;

  @override
  void paint(Canvas canvas, Size size) {
    // Bar width and gap are derived from canvas width so they fill edge-to-edge
    const double barFraction = 0.55; // bar takes 55% of each slot
    final slotW = size.width / _barCount;
    final barW = slotW * barFraction;

    final centerY = size.height / 2;
    final maxH = size.height * 0.80;
    final minH = size.height * 0.06;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _barCount; i++) {
      final phase = (i / _barCount) * math.pi * 2;
      double barH;
      if (active) {
        // Primary wave + secondary harmonic for organic feel
        final wave = math.sin(progress * math.pi * 2 + phase);
        final wave2 = math.sin(progress * math.pi * 4 + phase * 1.5) * 0.4;
        barH =
            minH + (maxH - minH) * ((wave + wave2 + 1.4) / 2.8).clamp(0.0, 1.0);
      } else {
        barH = minH;
      }

      // Gradient colour: cyan at peaks, mint at troughs
      final t = ((barH - minH) / (maxH - minH)).clamp(0.0, 1.0);
      final color = Color.lerp(
        const Color(0xFF00E5CC).withAlpha(80),
        const Color(0xFF00E5CC),
        t,
      )!;
      paint.color = color;

      final x = i * slotW + (slotW - barW) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - barH / 2, barW, barH),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_VoiceWavePainter old) =>
      old.progress != progress || old.active != active;
}
