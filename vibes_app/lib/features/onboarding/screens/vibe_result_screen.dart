import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/vibe_check_result.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../auth/screens/auth_screen.dart';

class VibeResultScreen extends StatefulWidget {
  const VibeResultScreen({
    super.key,
    required this.firstName,
    required this.audioFile,
    required this.result,
  });

  final String firstName;
  final File audioFile;
  final VibeCheckResult result;

  @override
  State<VibeResultScreen> createState() => _VibeResultScreenState();
}

class _VibeResultScreenState extends State<VibeResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0F12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout?', style: AppTextStyles.headingBold),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMono,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMono.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: AppTextStyles.bodyMono.copyWith(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await AuthSession.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  Future<void> _togglePlayback() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.audioFile.path));
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
    final r = widget.result;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable content ──
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: topPad + 72,
                        left: 20,
                        right: 20,
                        bottom: bottomPad + 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'Okay ${widget.firstName},\nHere\'s what I\'m hearing:',
                            style: AppTextStyles.displayLarge,
                          ),
                          const SizedBox(height: 24),

                          // Brain Readiness card
                          _BrainReadinessCard(result: r),
                          const SizedBox(height: 16),

                          // Frequency Score card
                          _FrequencyScoreCard(result: r),
                          const SizedBox(height: 24),

                          // Playback card
                          _PlaybackCard(
                            isPlaying: _playerState == PlayerState.playing,
                            position: _position,
                            duration: _duration,
                            onTap: _togglePlayback,
                            formatDuration: _formatDuration,
                          ),
                          const SizedBox(height: 32),

                          // Logout
                          GestureDetector(
                            onTap: _logout,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withAlpha(40),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Logout',
                                style: AppTextStyles.kamerikToggle.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
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
                    onTap: () => Navigator.of(context).pop(),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Brain Readiness Card
// ─────────────────────────────────────────────────────────────
class _BrainReadinessCard extends StatelessWidget {
  const _BrainReadinessCard({required this.result});
  final VibeCheckResult result;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              _IconBox(emoji: '🧠'),
              const SizedBox(width: 12),
              Text('Brain Readiness', style: AppTextStyles.headingBold),
            ],
          ),
          const SizedBox(height: 16),

          // Score + state row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        result.brainReadinessScore.toStringAsFixed(1),
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFA500),
                        ),
                      ),
                      Text(
                        ' /100',
                        style: AppTextStyles.bodyMono.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text('Just Now', style: AppTextStyles.caption),
                ],
              ),
              const Spacer(),
              // State
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFA500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result.brainState,
                        style: AppTextStyles.headingBold.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      result.brainStateSubtitle,
                      style: AppTextStyles.bodyMono.copyWith(
                        color: const Color(0xFFFFA500),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      'Your Brain State',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.white.withAlpha(20), height: 1),
          const SizedBox(height: 14),

          Text(result.brainStateDescription, style: AppTextStyles.bodyMono),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Frequency Score Card
// ─────────────────────────────────────────────────────────────
class _FrequencyScoreCard extends StatelessWidget {
  const _FrequencyScoreCard({required this.result});
  final VibeCheckResult result;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              _IconBox(emoji: '📡'),
              const SizedBox(width: 12),
              Text('Frequency Score', style: AppTextStyles.headingBold),
            ],
          ),
          const SizedBox(height: 16),

          // Score row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: score + hz
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${result.frequencyScore}',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' /100',
                          style: AppTextStyles.bodyMono.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text('Just Now', style: AppTextStyles.caption),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${result.frequencyHz.toInt()}',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 36,
                          ),
                        ),
                        Text(
                          ' Hz',
                          style: AppTextStyles.bodyMono.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      'Band: ${result.frequencyBandMin.toInt()}–${result.frequencyBandMax.toInt()} Hz',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),

              // Right: label + cta + vibing
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Recovering badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.frequencyLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFB5D96A),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.frequencyCta} →→',
                    style: AppTextStyles.bodyMono.copyWith(fontSize: 11),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 24),
                  Text('Vibing With You', style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${result.vibingWithYouCount}',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3A2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'nearby',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGreen,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${result.vibingActiveInBand} active in your band',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Playback Card
// ─────────────────────────────────────────────────────────────
class _PlaybackCard extends StatelessWidget {
  const _PlaybackCard({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onTap,
    required this.formatDuration,
  });

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onTap;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your Recording', style: AppTextStyles.headingBold),
              const Spacer(),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.knobOuter,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentCyan,
              ),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(position), style: AppTextStyles.caption),
              Text(formatDuration(duration), style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.knobCenter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.emoji});
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    );
  }
}
