import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'knob_widget.dart';
import 'onboarding_page_indicator.dart';
import 'privacy_badge.dart';
import 'talk_button.dart';

class OnboardingBottomPanel extends StatelessWidget {
  const OnboardingBottomPanel({
    super.key,
    required this.panelHeight,
    required this.knobSize,
    required this.bottomPad,
    required this.isRecording,
    required this.talkEnabled,
    required this.talkAnimationEnabled,
    required this.onTalkTap,
    this.title = 'Catching Your Vibe',
    this.subtitle = 'Tap Talk to start.',
    this.pageCount = 5,
    this.activeIndex = 0,
    this.onClose,
  });

  final double panelHeight;
  final double knobSize;
  final double bottomPad;
  final bool isRecording;
  final bool talkEnabled;
  final bool talkAnimationEnabled;
  final VoidCallback onTalkTap;
  final String title;
  final String subtitle;
  final int pageCount;
  final int activeIndex;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final totalHeight = panelHeight + bottomPad;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      // Painter draws the rounded top border OUTSIDE the clip so corners are visible
      child: CustomPaint(
        painter: _TopBorderPainter(),
        child: ClipPath(
          clipper: _PanelClipper(),
          child: Container(
            color: AppColors.surfacePanel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 14),
                const PrivacyBadge(),
                const SizedBox(height: 8),

                // Title row — text truly centered, button pinned right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const SizedBox(width: 38),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.headingBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const _KeyboardButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMono,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Knobs fill remaining space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KnobWidget(size: knobSize, isSpinning: isRecording),
                        KnobWidget(size: knobSize, isSpinning: isRecording),
                      ],
                    ),
                  ),
                ),

                // Action row: TALK | dots | X
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: bottomPad > 0 ? bottomPad : 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TalkButton(
                        onTap: onTalkTap,
                        enabled: talkEnabled,
                        animationEnabled: talkAnimationEnabled,
                      ),
                      OnboardingPageIndicator(
                        count: pageCount,
                        activeIndex: activeIndex,
                      ),
                      _CloseButton(onTap: onClose),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Draws the rounded top border on top of (outside) the ClipPath
class _TopBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 28.0;
    final paint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(size.width - r, 0)
      ..arcToPoint(
        Offset(size.width, r),
        radius: const Radius.circular(r),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TopBorderPainter old) => false;
}

class _PanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 28.0;
    return Path()
      ..moveTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_PanelClipper old) => false;
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.knobCenter,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.knobOuter, width: 1),
      ),
      child: const Icon(
        Icons.grid_view_rounded,
        color: AppColors.textSecondary,
        size: 18,
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.knobCenter,
          border: Border.all(color: AppColors.knobOuter, width: 1),
        ),
        child: const Icon(
          Icons.close,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
