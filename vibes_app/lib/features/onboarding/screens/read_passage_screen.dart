// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/mic_permission_guard.dart';
import 'vibe_loading_screen.dart';

const _passage =
    'My voice shows my brain.\nMy brain responds to sound.\nSound changes my state.\n\n'
    'I can measure it. I can restore it. I can prove it changed. This is how I\n'
    'take care of my brain. And where ever I am today -- I am enough.';

class ReadPassageScreen extends StatefulWidget {
  const ReadPassageScreen({
    super.key,
    required this.firstName,
    required this.age,
    this.latitude,
    this.longitude,
  });

  final String firstName;
  final int age;
  final double? latitude;
  final double? longitude;

  @override
  State<ReadPassageScreen> createState() => _ReadPassageScreenState();
}

class _ReadPassageScreenState extends State<ReadPassageScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _rotationController;

  final FlutterTts _tts = FlutterTts();
  bool _ttsDisposed = false;
  bool _isSpeaking = false;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isSubmitting = false;

  static const int _minRecordSeconds = 20;
  int _activeRecordSeconds = 0;
  Timer? _recordTimer;

  bool get _canSubmit =>
      _isRecording && _activeRecordSeconds >= _minRecordSeconds;

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

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    Future.delayed(const Duration(milliseconds: 1000), _speakIntro);
  }

  Future<void> _speakIntro() async {
    if (_ttsDisposed) return;
    await _tts.setLanguage('en-US');
    if (_ttsDisposed) return;
    await _tts.setSpeechRate(0.35);
    if (_ttsDisposed) return;
    _tts.setStartHandler(() {
      if (!_ttsDisposed) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() async {
      if (_ttsDisposed) return;
      setState(() => _isSpeaking = false);
      await Future.delayed(const Duration(seconds: 1));
      if (!_ttsDisposed && mounted) _startRecording();
    });
    _tts.setCancelHandler(() {
      if (!_ttsDisposed) setState(() => _isSpeaking = false);
    });
    await _tts.speak('Read this passage out loud.');
  }

  @override
  void dispose() {
    _ttsDisposed = true;
    _tts.stop();
    _recordTimer?.cancel();
    _fadeController.dispose();
    _rotationController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final granted = await MicPermissionGuard.check(context);
    if (!mounted) return;
    if (!granted) {
      Navigator.of(context).pop();
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/vibe_check_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
    if (mounted) {
      setState(() => _isRecording = true);
      _rotationController.repeat();
      _startTimer();
    }
  }

  void _startTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isRecording && !_isPaused) {
        setState(() => _activeRecordSeconds++);
      }
    });
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorder.resume();
      _rotationController.repeat();
      _startTimer();
    } else {
      await _recorder.pause();
      _rotationController.stop();
      _recordTimer?.cancel();
    }
    if (mounted) setState(() => _isPaused = !_isPaused);
  }

  Future<void> _stopAndSubmit() async {
    if (_isSubmitting) return;

    if (!_canSubmit) {
      _showError('Please read the full passage before submitting.');
      return;
    }

    _recordTimer?.cancel();
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
          latitude: widget.latitude,
          longitude: widget.longitude,
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
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Top nav bar ──
          Container(
            padding: EdgeInsets.only(
              top: topPad + 8,
              left: 20,
              right: 20,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: Colors.white.withAlpha(15), width: 1),
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
                      border: Border.all(color: AppColors.knobOuter, width: 1),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
                AppIconBadge(isSpeaking: _isSpeaking),
              ],
            ),
          ),

          // ── Scrollable passage (fills remaining space) ──
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'READ THIS PASSAGE OUTLOUD',
                        style: AppTextStyles.caption.copyWith(
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _passage,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'SF Pro Display',
                          fontSize: 24,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          height: 40 / 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Record bar ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(15), width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
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
                              ? (_isPaused ? 'Paused' : 'VAIA is listening...')
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
                        onTap: _canSubmit ? _stopAndSubmit : null,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _canSubmit
                                ? AppColors.accentGradient
                                : null,
                            color: _canSubmit ? null : AppColors.knobCenter,
                          ),
                          child: Icon(
                            Icons.check,
                            color: _canSubmit
                                ? Colors.black
                                : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // ── VAIA rotating image ──
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: bottomPad + 20),
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (_, child) => Transform.rotate(
                angle: _rotationController.value * 2 * 3.141592653589793,
                child: child,
              ),
              child: Image.asset(
                'assets/images/VAIA.png',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
