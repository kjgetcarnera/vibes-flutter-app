import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/services/vibes_audio_handler.dart';
import 'package:flutter/material.dart';
// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/models/vibe_check_result.dart';
import '../../../core/services/audio_service_manager.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../auth/screens/auth_screen.dart';
import 'read_passage_screen.dart';

class VibeResultScreen extends StatefulWidget {
  const VibeResultScreen({
    super.key,
    required this.firstName,
    required this.age,
    required this.audioFile,
    required this.result,
    this.latitude,
    this.longitude,
    this.passageIndex,
  });

  final String firstName;
  final int age;
  final File audioFile;
  final VibeCheckResult result;
  final double? latitude;
  final double? longitude;
  final int? passageIndex;

  @override
  State<VibeResultScreen> createState() => _VibeResultScreenState();
}

class _VibeResultScreenState extends State<VibeResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AudioPlayer _tts = AudioPlayer();
  bool _ttsDisposed = false;

  // final AudioPlayer _player = AudioPlayer();
  // PlayerState _playerState = PlayerState.stopped;
  // Duration _position = Duration.zero;
  // Duration _duration = Duration.zero;

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
    Future.delayed(const Duration(milliseconds: 800), _speakIntro);

    // _player.onPlayerStateChanged.listen((s) {
    //   if (mounted) setState(() => _playerState = s);
    // });
    // _player.onPositionChanged.listen((p) {
    //   if (mounted) setState(() => _position = p);
    // });
    // _player.onDurationChanged.listen((d) {
    //   if (mounted) setState(() => _duration = d);
    // });
  }

  Future<void> _speakIntro() async {
    if (_ttsDisposed) return;
    await _tts.play(AssetSource('audio/FOurth-voice.mp3'));
  }

  @override
  void dispose() {
    _ttsDisposed = true;
    _tts.dispose();
    _fadeController.dispose();
    // _player.dispose();
    super.dispose();
  }

  void _reRecord() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ReadPassageScreen(
          firstName: widget.firstName,
          age: widget.age,
          latitude: widget.latitude,
          longitude: widget.longitude,
          excludePassageIndex: widget.passageIndex,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(180),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(20), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withAlpha(25),
                  border: Border.all(color: Colors.redAccent.withAlpha(80)),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              Text('Logout?', style: AppTextStyles.headingBold),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                style: AppTextStyles.bodyMono.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyMono.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.redAccent.withAlpha(120),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: AppTextStyles.bodyMono.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  // Future<void> _togglePlayback() async {
  //   if (_playerState == PlayerState.playing) {
  //     await _player.pause();
  //   } else {
  //     await _player.play(DeviceFileSource(widget.audioFile.path));
  //   }
  // }

  // String _formatDuration(Duration d) {
  //   final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  //   final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  //   return '$m:$s';
  // }

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
                            style: const TextStyle(
                              fontFamily: 'PPSupplyMono',
                              fontSize: 24,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w300,
                              height: 34 / 24,
                              letterSpacing: -0.48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Brain Readiness card
                          _BrainReadinessCard(result: r),
                          const SizedBox(height: 16),

                          // Frequency Score card
                          _FrequencyScoreCard(result: r),
                          const SizedBox(height: 24),

                          // Recommended audio carousel
                          if (r.recommendedAudios.isNotEmpty) ...[
                            _AudioCarousel(audios: r.recommendedAudios),
                            const SizedBox(height: 30),
                          ],

                          // Listening suggestion
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: Text(
                              'Chosen for your brain state right now.',
                              style: AppTextStyles.bodyMono.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Re-record
                          GestureDetector(
                            onTap: _reRecord,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Read Again after listening',
                                style: AppTextStyles.kamerikToggle.copyWith(
                                  fontSize: 16,
                                  color: AppColors.background,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [const AppIconBadge()],
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
    final c1 =
        _parseColor(result.brainReadinessColors.firstOrNull) ??
        const Color(0xFFF9DF17);
    final c2 = result.brainReadinessColors.length > 1
        ? (_parseColor(result.brainReadinessColors[1]) ?? c1)
        : c1;
    final gradient = LinearGradient(colors: [c1, c2]);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              _IconBox(assetPath: AppAssets.brainReadiness),
              const SizedBox(width: 12),
              Text('Brain Readiness', style: _kCardTitle),
            ],
          ),
          const SizedBox(height: 18),

          // Score + state row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left — big score with gradient
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => gradient.createShader(b),
                          child: Text(
                            result.brainReadinessScore.toStringAsFixed(1),
                            style: _kBigNumber.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('/100', style: _kMuted),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Just Now', style: _kCaption),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right — state info
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => gradient.createShader(b),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            _formatState(result.brainState),
                            style: _kStateName,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ShaderMask(
                      shaderCallback: (b) => gradient.createShader(b),
                      child: Text(
                        result.brainStateSubtitle,
                        style: _kMonoSm.copyWith(color: Colors.white),
                        textAlign: TextAlign.right,
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('Your Brain State', style: _kCaption),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withAlpha(20), height: 1),
          const SizedBox(height: 14),

          Text(result.brainStateDescription, style: _kBody),
          if (result.brainReadinessRecommendation.isNotEmpty) ...[
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (b) => gradient.createShader(b),
              child: Text(
                result.brainReadinessRecommendation,
                style: _kMonoSm.copyWith(color: Colors.white),
              ),
            ),
          ],
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
    final c1 =
        _parseColor(result.frequencyColors.firstOrNull) ?? AppColors.accentCyan;
    final c2 = result.frequencyColors.length > 1
        ? (_parseColor(result.frequencyColors[1]) ?? c1)
        : c1;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              _IconBox(assetPath: AppAssets.frequencyScore),
              const SizedBox(width: 12),
              Text('Frequency Score', style: _kCardTitle),
            ],
          ),
          const SizedBox(height: 18),

          // Hz + badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left — Hz number (replaces old score)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            LinearGradient(colors: [c1, c2]).createShader(b),
                        child: Text(
                          result.frequencyHz.toStringAsFixed(1),
                          style: _kBigNumber.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Hz', style: _kBody),
                    ],
                  ),
                  if (result.frequencyBandMin > 0 ||
                      result.frequencyBandMax > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c2.withAlpha(200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Band: ${result.frequencyBandMin.toStringAsFixed(0)}–${result.frequencyBandMax.toStringAsFixed(0)} Hz',
                        style: _kCaption.copyWith(
                          color: const Color(0xFFE8E8E8),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const Spacer(),

              // Right — badge + CTA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: c1.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c1.withAlpha(100)),
                    ),
                    child: Text(
                      _formatState(result.frequencyTag),
                      style: _kCaption.copyWith(color: c1, letterSpacing: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withAlpha(20), height: 1),
          const SizedBox(height: 14),

          // Meaning + recommendation — full width
          Text(result.frequencyMeaning, style: _kMonoSm),
          if (result.frequencyRecommendation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              result.frequencyRecommendation,
              style: _kMonoSm.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card-local text styles
// ─────────────────────────────────────────────────────────────
final _kBigNumber = GoogleFonts.inter(
  fontSize: 50,
  fontWeight: FontWeight.w700,
  color: const Color(0xFFFFFEFE),
  letterSpacing: -1,
);

final _kCardTitle = GoogleFonts.inter(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: const Color(0xFFFFFEFE),
  letterSpacing: -0.3,
);

final _kStateName = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: const Color(0xFFFFFEFE),
  letterSpacing: -0.2,
);

const _kBody = TextStyle(
  fontFamily: 'PPSupplyMono',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: Color(0xB3FFFEFE),
  height: 1.5,
);

const _kMonoSm = TextStyle(
  fontFamily: 'PPSupplyMono',
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: Color(0xFFFFFEFE),
  height: 1.4,
);

const _kCaption = TextStyle(
  fontFamily: 'PPSupplyMono',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color(0x80939AA6),
  letterSpacing: 0.6,
);

const _kMuted = TextStyle(
  fontFamily: 'PPSupplyMono',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0x668E8E93),
);

// ─────────────────────────────────────────────────────────────
// Playback Card
// ─────────────────────────────────────────────────────────────
// class _PlaybackCard extends StatelessWidget {
//   const _PlaybackCard({
//     required this.isPlaying,
//     required this.position,
//     required this.duration,
//     required this.onTap,
//     required this.formatDuration,
//   });

//   final bool isPlaying;
//   final Duration position;
//   final Duration duration;
//   final VoidCallback onTap;
//   final String Function(Duration) formatDuration;

//   @override
//   Widget build(BuildContext context) {
//     final progress = duration.inMilliseconds > 0
//         ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
//         : 0.0;

//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text('Your Recording', style: AppTextStyles.headingBold),
//               const Spacer(),
//               GestureDetector(
//                 onTap: onTap,
//                 child: Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: AppColors.accentGradient,
//                   ),
//                   child: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.black,
//                     size: 22,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: AppColors.knobOuter,
//               valueColor: const AlwaysStoppedAnimation<Color>(
//                 AppColors.accentCyan,
//               ),
//               minHeight: 3,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(formatDuration(position), style: AppTextStyles.caption),
//               Text(formatDuration(duration), style: AppTextStyles.caption),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

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
        color: const Color(0x332C2C2E), // rgba(44,44,46,0.20)
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(assetPath, width: 40, height: 40, fit: BoxFit.cover),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// File-level helpers
// ─────────────────────────────────────────────────────────────

/// Parses a hex color string like "#4CAF50" into a Color.
Color? _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final clean = hex.replaceAll('#', '').trim();
  if (clean.length == 6) {
    final value = int.tryParse('FF$clean', radix: 16);
    return value != null ? Color(value) : null;
  }
  if (clean.length == 8) {
    final value = int.tryParse(clean, radix: 16);
    return value != null ? Color(value) : null;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────
// Audio Track Carousel
// ─────────────────────────────────────────────────────────────
class _AudioCarousel extends StatefulWidget {
  const _AudioCarousel({required this.audios});
  final List<RecommendedAudio> audios;

  @override
  State<_AudioCarousel> createState() => _AudioCarouselState();
}

class _AudioCarouselState extends State<_AudioCarousel> {
  // Audio is now routed through VibesAudioHandler so the OS shows lock screen
  // controls (thumbnail, progress, play/pause/stop) on both iOS and Android.
  // The raw AudioPlayer inside the handler still drives all playback — nothing
  // about the audio behaviour has changed, only the OS media session is added.
  late final _handler = AudioServiceManager.instance.handler;

  final PageController _pageController = PageController(viewportFraction: 0.88);

  int _currentPage = 0;
  int? _playingId;
  int? _loadingId;
  late final List<RecommendedAudio> _queuedAudios;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Only audios with a URL enter the queue — index must stay in sync
    _queuedAudios = widget.audios.where((a) => a.audioUrl.isNotEmpty).toList();

    _handler.loadQueue(
      _queuedAudios
          .map(
            (a) => QueueEntry(
              item: MediaItem(
                id: a.id.toString(),
                title: a.name,
                artist: a.subtitle,
                artUri: a.coverImageUrl.isNotEmpty
                    ? Uri.tryParse(a.coverImageUrl)
                    : null,
              ),
              audioUrl: a.audioUrl,
            ),
          )
          .toList(),
    );

    _handler.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() {
        _playerState = s;
        if (s == PlayerState.playing ||
            s == PlayerState.paused ||
            s == PlayerState.completed) {
          _loadingId = null;
        }
      });
      if (s == PlayerState.completed) {
        setState(() {
          _playingId = null;
          _position = Duration.zero;
        });
      }
    });
    _handler.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _handler.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    // Sync UI when user taps next/previous on the lock screen
    _handler.onSkip.listen((index) {
      if (!mounted) return;
      final audio = widget.audios[index];
      setState(() {
        _playingId = audio.id;
        _currentPage = index;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    // When the user taps Stop on the lock screen / notification, clear the
    // active-track indicator in the UI so it stays in sync.
    _handler.onExternalStop.listen((_) {
      if (mounted) {
        setState(() {
          _playingId = null;
          _position = Duration.zero;
          _duration = Duration.zero;
          _playerState = PlayerState.stopped;
        });
      }
    });
  }

  @override
  void dispose() {
    // Stop audio when leaving the screen (back, re-record, logout).
    // Does NOT affect background/lock screen — dispose is only called on
    // navigation, not when the app moves to the background.
    _handler.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(RecommendedAudio audio) async {
    if (_playingId == audio.id) {
      if (_playerState == PlayerState.playing) {
        await _handler.pause();
      } else {
        await _handler.play();
      }
    } else {
      final index = _queuedAudios.indexWhere((a) => a.id == audio.id);
      if (index == -1) return;
      setState(() {
        _playingId = audio.id;
        _loadingId = audio.id;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      await _handler.playAudio(index: index);
      // Fallback: clear loader if stream never fired
      if (mounted && _loadingId == audio.id) {
        setState(() => _loadingId = null);
      }
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audios.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Your 40Hz restorative audio is ready. Hit play. Let it work.",
            style: const TextStyle(
              fontFamily: 'PPSupplyMono',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFFFFFFFE),
              letterSpacing: -0.48,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.audios.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final audio = widget.audios[i];
              final isActive = _playingId == audio.id;
              final isPlaying = isActive && _playerState == PlayerState.playing;
              final progress = isActive && _duration.inMilliseconds > 0
                  ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(
                      0.0,
                      1.0,
                    )
                  : 0.0;

              final bool hasUrl = audio.audioUrl.isNotEmpty;

              return AnimatedScale(
                scale: _currentPage == i ? 1.0 : 0.96,
                duration: const Duration(milliseconds: 300),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final coverWidth = constraints.maxWidth * 0.38;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111316),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withAlpha(isActive ? 35 : 15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // ── Cover image (30% width) ──
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: audio.coverImageUrl.isNotEmpty
                                ? Image.network(
                                    audio.coverImageUrl,
                                    key: ValueKey(audio.coverImageUrl),
                                    width: coverWidth,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null
                                        ? child
                                        : _coverPlaceholder(coverWidth),
                                    errorBuilder: (_, __, ___) =>
                                        _coverPlaceholder(coverWidth),
                                  )
                                : _coverPlaceholder(coverWidth),
                          ),

                          // ── Right panel ──
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                12,
                                12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TRACK label + share icon
                                  Row(
                                    children: [
                                      const Text(
                                        '40Hz RESTORATIVE AUDIO',
                                        style: TextStyle(
                                          fontFamily: 'Kamerik105',
                                          fontSize: 10,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700,
                                          height: 24 / 10,
                                          letterSpacing: 0.2,
                                          color: Color(0xFF646464),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 7),

                                  // Track name
                                  Text(
                                    audio.name,
                                    style: const TextStyle(
                                      fontFamily: 'Kamerik105',
                                      fontSize: 16,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                      height: 24 / 16,
                                      letterSpacing: 0.4,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Subtitle
                                  Text(
                                    audio.subtitle,
                                    style: const TextStyle(
                                      fontFamily: 'Kamerik105',
                                      fontSize: 10,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w400,
                                      height: 20 / 10,
                                      letterSpacing: 0.2,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  // Play button + waveform row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Play/pause
                                      GestureDetector(
                                        onTap: hasUrl
                                            ? () => _togglePlay(audio)
                                            : null,
                                        child: Opacity(
                                          opacity: hasUrl ? 1.0 : 0.35,
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.knobCenter,
                                              border: Border.all(
                                                color: AppColors.knobOuter,
                                                width: 1,
                                              ),
                                            ),
                                            child: _loadingId == audio.id
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Color(0xFF2FE17A)),
                                                    ),
                                                  )
                                                : hasUrl
                                                ? ShaderMask(
                                                    shaderCallback: (b) =>
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF2FE17A),
                                                            Color(0xFF00FFF7),
                                                          ],
                                                        ).createShader(b),
                                                    child: Icon(
                                                      isPlaying
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.play_disabled,
                                                    color: Color(0xFF3A3F4A),
                                                    size: 20,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Waveform + time stacked
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 28,
                                              child: CustomPaint(
                                                painter: _WaveformPainter(
                                                  progress: progress.toDouble(),
                                                  seed: audio.id,
                                                ),
                                                size: const Size(
                                                  double.infinity,
                                                  28,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isActive
                                                  ? '${_fmt(_position)}  |  ${_fmt(_duration)}'
                                                  : '00:00  |  --:--',
                                              style: const TextStyle(
                                                fontFamily: 'PPSupplyMono',
                                                fontSize: 12,
                                                color: Color(0xFF939AA6),
                                                letterSpacing: 0.16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.audios.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF2FE17A), Color(0xFF00FFF7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: active ? null : Colors.white.withAlpha(40),
              ),
            );
          }),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 10),
          child: Text(
            "10-15 minutes is all it takes. We'll read your voice again after to show you the shift.",
            style: const TextStyle(
              fontFamily: 'PPSupplyMono',
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Color(0xFFFFFFFE),
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder(double width) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1D24), Color(0xFF0F1116)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF2FE17A), Color(0xFF00FFF7)],
              ).createShader(b),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '40Hz',
              style: TextStyle(
                fontFamily: 'Kamerik105',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3A3F4A),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Waveform Painter
// ─────────────────────────────────────────────────────────────
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.progress, required this.seed});

  final double progress;
  final int seed;

  List<double> _bars(int count) {
    final r = <double>[];
    var v = seed * 1234567;
    for (var i = 0; i < count; i++) {
      v = (v * 1103515245 + 12345) & 0x7fffffff;
      r.add(0.2 + (v % 100) / 100.0 * 0.8);
    }
    return r;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 36;
    const barSpacing = 2.0;
    final barWidth = (size.width - barSpacing * (barCount - 1)) / barCount;
    final bars = _bars(barCount);

    final playedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2FE17A), Color(0xFF00FFF7)],
      ).createShader(Offset.zero & size)
      ..strokeCap = StrokeCap.round;

    final unplayedPaint = Paint()
      ..color = Colors.white.withAlpha(35)
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < barCount; i++) {
      final x = i * (barWidth + barSpacing);
      final barH = bars[i] * size.height;
      final top = (size.height - barH) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, barH),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rect,
        i / barCount < progress ? playedPaint : unplayedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.seed != seed;
}

/// Converts snake_case or hyphen-case state strings to Title Case.
/// e.g. "over_activated" → "Over Activated", "Ready" → "Ready"
String _formatState(String state) {
  return state
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .map(
        (w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}
