// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/vibe_api_service.dart';
import '../../../core/widgets/app_icon_badge.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _startRecording();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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

    print('[VibeCheck] isRecording=$_isRecording isPaused=$_isPaused');

    final path = await _recorder.stop();
    setState(() => _isRecording = false);

    print('[VibeCheck] recorded file path: $path');

    if (path == null) {
      print(
        '[VibeCheck] ERROR: path is null — recording never started or failed',
      );
      _showError('Recording failed. Please try again.');
      setState(() => _isSubmitting = false);
      return;
    }

    final file = File(path);
    final fileSize = await file.exists() ? await file.length() : -1;
    print(
      '[VibeCheck] file exists: ${await file.exists()}, size: $fileSize bytes',
    );
    print(
      '[VibeCheck] payload → firstName: ${widget.firstName}, age: ${widget.age}',
    );

    try {
      await VibeApiService.submitVibeCheck(
        firstName: widget.firstName,
        age: widget.age,
        audioFile: file,
      );
      print('[VibeCheck] API success');
    } catch (e) {
      print('[VibeCheck] API ERROR (skipped for now): $e');
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
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
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;

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
                  bottom: bottomPad + 120,
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
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: Colors.white.withAlpha(15), width: 1),
                ),
              ),
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
                        // Recording indicator dot
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
                        // Pause / Resume
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
                        // Submit / Done
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
                              color: _isRecording ? null : AppColors.knobCenter,
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
          ),
        ],
      ),
    );
  }
}
