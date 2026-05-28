// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/mic_permission_guard.dart';
import 'consent_screen.dart';
import 'vibe_loading_screen.dart';

class _Passage {
  const _Passage({
    required this.title,
    required this.author,
    required this.text,
    required this.footer,
  });
  final String title;
  final String author;
  final String text;
  final String footer;
}

const _passages = [
  _Passage(
    title: 'Still I Rise',
    author: '— Maya Angelou',
    text:
        'You may write me down in history\nWith your bitter, twisted lies,\n'
        'You may trod me in the very dirt\nBut still, like dust, I\'ll rise.\n\n'
        'Out of the huts of history\'s shame I rise\n'
        'Up from a past that\'s rooted in pain I rise\n'
        'Bringing the gifts that my ancestors gave,\n'
        'I am the dream and the hope of the slave.\n'
        'I rise. I rise. I rise.',
    footer: 'Excerpt — full poem at poets.org',
  ),
  _Passage(
    title: 'I\'m in a Vibes State of Mind',
    author: '— Joanna Pena Bickley',
    text:
        'Today, I reclaim my attention as sacred.\n'
        'I turn away from the noise that scatters my mind,\n'
        'and return to the quiet center of my own breath and voice.\n\n'
        'I am the authentic intelligence — channeling the ancestral\n'
        'intelligence of voice and sound to build a world that works\n'
        'for everyone, everywhere, every day.\n'
        'My voice is not small. Every word I speak,\n'
        'every tone I carry, is a vibration that shapes my world.\n\n'
        'May my voice be a vital sign of my wholeness.\n'
        'For the gift of this breath, this brain, this day — thank you.',
    footer: 'Original MANTRA passage',
  ),
  _Passage(
    title: 'Signal',
    author: '— VAIA × Vibes AI',
    text:
        'My voice is data.\nMy data is truth.\n'
        'This brain — right now —\nis doing something extraordinary just to get me here.\n\n'
        'I don\'t need to perform.\nI don\'t need to optimize.\nI just need to speak.\n\n'
        'Every Hz I carry is a story.\n'
        'Every pause, every breath, every hesitation\nis signal, not noise.\n\n'
        'I am not broken. I am transmitting.\nAnd today, I choose to listen back.',
    footer: 'Original passage – written for MANTRA',
  ),
];

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

  final AudioPlayer _tts = AudioPlayer();
  bool _ttsDisposed = false;
  bool _isSpeaking = false;

  int _passageIndex = 0;
  bool _recordingStarted = false;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _recordedPath;

  static const int _minRecordSeconds = 30;
  int _activeRecordSeconds = 0;
  Timer? _recordTimer;

  // Silence detection — rolling average over last 3 readings
  // Calibrated from real device: room noise ≈ -28 to -30, speech ≈ -4 to -17
  static const double _silenceThresholdDb = -24.0;
  static const int _silenceWarnSeconds = 6;
  static const int _silenceAutoPauseSeconds = 20;
  final List<double> _ampHistory = [];
  int _silenceSeconds = 0;
  bool _silenceWarning = false;
  bool _checkingAmplitude = false;
  double _micLevel = 0.0; // 0.0–1.0 normalised for the level bar

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
    _tts.onPlayerStateChanged.listen((s) {
      if (_ttsDisposed) return;
      setState(() => _isSpeaking = s == PlayerState.playing);
    });
    await _tts.play(AssetSource('audio/THird-Voice.mp3'));
  }

  @override
  void dispose() {
    _ttsDisposed = true;
    _tts.dispose();
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
    _checkingAmplitude = false;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecording || _isPaused) return;
      setState(() => _activeRecordSeconds++);
      _pollAmplitude();
    });
  }

  Future<void> _pollAmplitude() async {
    if (_checkingAmplitude || !_isRecording || _isPaused) return;
    _checkingAmplitude = true;
    try {
      final amp = await _recorder.getAmplitude();
      if (!mounted || !_isRecording || _isPaused) return;

      final db = amp.current;
      // print('[MIC] amplitude: ${db.toStringAsFixed(1)} dBFS');

      // Normalise dBFS (-60 → 0.0, 0 → 1.0) for the level bar
      final level = ((db + 60.0) / 60.0).clamp(0.0, 1.0);

      // Rolling average over last 3 readings for stable detection
      _ampHistory.add(db);
      if (_ampHistory.length > 3) _ampHistory.removeAt(0);
      final avgDb = _ampHistory.reduce((a, b) => a + b) / _ampHistory.length;
      final isSilent = avgDb < _silenceThresholdDb;

      if (isSilent) {
        final newSeconds = _silenceSeconds + 1;
        if (newSeconds >= _silenceAutoPauseSeconds) {
          await _recorder.pause();
          _rotationController.stop();
          _recordTimer?.cancel();
          if (mounted) {
            // Strip silent seconds from the active count — they don't count toward the 30s minimum
            final validSeconds = (_activeRecordSeconds - newSeconds).clamp(
              0,
              _activeRecordSeconds,
            );
            setState(() {
              _isPaused = true;
              _activeRecordSeconds = validSeconds;
              _silenceSeconds = 0;
              _silenceWarning = false;
              _micLevel = 0.0;
            });
            _showError(
              'No voice detected — recording paused. Tap ▶ to resume.',
            );
          }
        } else {
          setState(() {
            _silenceSeconds = newSeconds;
            _silenceWarning = newSeconds >= _silenceWarnSeconds;
            _micLevel = level;
          });
        }
      } else {
        setState(() {
          _silenceSeconds = 0;
          _silenceWarning = false;
          _micLevel = level;
        });
      }
    } catch (e) {
      // print('[MIC] getAmplitude error: $e');
    } finally {
      _checkingAmplitude = false;
    }
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorder.resume();
      _rotationController.repeat();
      _ampHistory.clear();
      setState(() {
        _silenceSeconds = 0;
        _silenceWarning = false;
        _checkingAmplitude = false;
        _micLevel = 0.0;
      });
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
    _rotationController.stop();
    _ampHistory.clear();
    setState(() {
      _isSubmitting = true;
      _isRecording = false;
      _silenceSeconds = 0;
      _silenceWarning = false;
      _checkingAmplitude = false;
      _micLevel = 0.0;
    });

    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      path = null;
    }

    if (!mounted) return;

    if (path == null) {
      _showError('Recording failed. Please try again.');
      setState(() {
        _isSubmitting = false;
        _isRecording = false;
      });
      return;
    }

    setState(() {
      _recordedPath = path;
      _submitted = true;
      _isSubmitting = false;
    });
  }

  void _navigateToLoading() {
    if (_recordedPath == null) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VibeLoadingScreen(
          firstName: widget.firstName,
          age: widget.age,
          audioFile: File(_recordedPath!),
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
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConsentScreen(
          firstName: widget.firstName,
          age: widget.age,
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
      ),
    );
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
                      // Header label
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.accentGradient2.createShader(bounds),
                        child: Text(
                          'VOICE READING',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Read aloud at your natural pace. No performance — just your voice, right now.',
                        style: AppTextStyles.bodyMono.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      // Passage title row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _passages[_passageIndex].title,
                                  style: AppTextStyles.headingBold.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _passages[_passageIndex].author,
                                  style: AppTextStyles.bodyMono.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Swap button — only when not recording
                          if (!_recordingStarted)
                            GestureDetector(
                              onTap: () => setState(
                                () => _passageIndex =
                                    (_passageIndex + 1) % _passages.length,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.knobCenter,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.knobOuter,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'swap',
                                  style: AppTextStyles.bodyMono.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Passage text
                      Text(
                        _passages[_passageIndex].text,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'SF Pro Display',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          height: 40 / 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Footer note
                      Text(
                        _passages[_passageIndex].footer,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom bar ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(15), width: 1),
              ),
            ),
            padding: EdgeInsets.fromLTRB(24, 14, 24, bottomPad + 14),
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
                : _submitted
                // ── Captured confirmation + navigate button ──
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2026),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .accentGradient2
                                  .createShader(bounds),
                              child: Text(
                                '✓ ${_activeRecordSeconds}s captured',
                                style: AppTextStyles.bodyMono.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'reading your frequency…',
                              style: AppTextStyles.bodyMono.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _navigateToLoading,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Read My Frequency →',
                            style: TextStyle(
                              fontFamily: 'Kamerik105',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.36,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : !_recordingStarted
                // "start recording" button
                ? GestureDetector(
                    onTap: _isSpeaking
                        ? null
                        : () {
                            setState(() => _recordingStarted = true);
                            _startRecording();
                          },
                    child: Opacity(
                      opacity: _isSpeaking ? 0.4 : 1.0,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isSpeaking
                              ? 'VAIA is speaking...'
                              : 'Start Recording',
                          style: const TextStyle(
                            fontFamily: 'Kamerik105',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.36,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                  )
                // Record controls bar + rotating VAIA below
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
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
                                  ? (_isPaused
                                        ? 'Paused'
                                        : 'VAIA is listening...')
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
                      const SizedBox(height: 16),
                      // Mic level bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 4,
                          width: double.infinity,
                          color: Colors.white10,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _micLevel,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: _silenceWarning
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFFB020),
                                          Color(0xFFFF6B00),
                                        ],
                                      )
                                    : AppColors.accentGradient2,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _canSubmit
                          ? ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .accentGradient2
                                  .createShader(bounds),
                              child: Text(
                                'Solid — tap ✓ when you\'re done',
                                style: AppTextStyles.bodyMono.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : _silenceWarning
                          ? Text(
                              '🎙 We can\'t hear you — speak up or check your mic',
                              style: AppTextStyles.bodyMono.copyWith(
                                color: const Color(0xFFFFB020),
                              ),
                            )
                          : Text(
                              'Aim for 30-60 seconds',
                              style: AppTextStyles.bodyMono.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                      const SizedBox(height: 12),
                      // Rotating VAIA image
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (_, child) => Transform.rotate(
                          angle:
                              _rotationController.value * 2 * 3.141592653589793,
                          child: child,
                        ),
                        child: Image.asset(
                          'assets/images/VAIA.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
