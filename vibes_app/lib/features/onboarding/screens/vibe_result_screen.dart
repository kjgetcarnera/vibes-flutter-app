import 'dart:io';
import 'package:flutter/material.dart';
// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
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

  @override
  void dispose() {
    _fadeController.dispose();
    // _player.dispose();
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
                          // _PlaybackCard(
                          //   isPlaying: _playerState == PlayerState.playing,
                          //   position: _position,
                          //   duration: _duration,
                          //   onTap: _togglePlayback,
                          //   formatDuration: _formatDuration,
                          // ),
                          // const SizedBox(height: 32),

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
    final c1 = _parseColor(result.brainReadinessColors.firstOrNull) ??
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — big score with gradient
              Column(
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

              const Spacer(),

              // Right — state info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot: gradient if two colors, flat if one
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
                      Text(_formatState(result.brainState), style: _kStateName),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ShaderMask(
                    shaderCallback: (b) => gradient.createShader(b),
                    child: Text(
                      result.brainStateSubtitle,
                      style: _kMonoSm.copyWith(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('Your Brain State', style: _kCaption),
                ],
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

          // Score row — matches Figma: score left, badge + CTA right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
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
                            result.frequencyScore.toStringAsFixed(1),
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

              // Right column — badge + CTA
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 130,
                    child: Text(
                      '${result.frequencyCta} →→',
                      style: _kMonoSm,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withAlpha(20), height: 1),
          const SizedBox(height: 14),

          // Hz row — left: Hz big, right: meaning + recommendation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — Hz
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
                          style: _kHzNumber.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('Hz', style: _kBody),
                    ],
                  ),
                  if (result.frequencyBandMin > 0 ||
                      result.frequencyBandMax > 0) ...[
                    const SizedBox(height: 6),
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

              const SizedBox(width: 16),

              // Right — meaning + recommendation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      result.frequencyMeaning,
                      style: _kMonoSm,
                      textAlign: TextAlign.right,
                    ),
                    if (result.frequencyRecommendation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        result.frequencyRecommendation,
                        style: _kMonoSm.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

final _kHzNumber = GoogleFonts.inter(
  fontSize: 36,
  fontWeight: FontWeight.w700,
  color: const Color(0xFFFFFEFE),
  letterSpacing: -0.5,
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
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Color(0xB3FFFEFE),
  height: 1.5,
);

const _kMonoSm = TextStyle(
  fontFamily: 'PPSupplyMono',
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: Color(0xFFFFFEFE),
  height: 1.4,
);

const _kCaption = TextStyle(
  fontFamily: 'PPSupplyMono',
  fontSize: 10,
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
