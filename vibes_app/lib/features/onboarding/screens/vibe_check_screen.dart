import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/onboarding_bottom_panel.dart';
import 'user_info_screen.dart';

class VibeCheckScreen extends StatefulWidget {
  const VibeCheckScreen({super.key});

  @override
  State<VibeCheckScreen> createState() => _VibeCheckScreenState();
}

class _VibeCheckScreenState extends State<VibeCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isRecording = false;
  final bool _talkEnabled = false;
  final bool _talkAnimationEnabled = false;

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

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserInfoScreen()),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTalkTap() {
    setState(() => _isRecording = !_isRecording);
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
    final screenHeight = mq.size.height;
    final screenWidth = mq.size.width;
    final bottomPad = mq.padding.bottom;
    final topPad = mq.padding.top;

    // Panel = 40% of screen height, content = 60%
    final panelHeight = screenHeight * 0.40;
    final knobSize = (screenWidth * 0.35).clamp(120.0, 185.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Scrollable content (60%) ──
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPad + 8,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: _AppIconBadge(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Welcome to your first vibe check. Think of this like morning pages, but spoken.',
                              style: AppTextStyles.displayMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Every day: Your voice reveals your brain\'s state. I give you sound to shift it. Your brain readiness and frequency prove it changed.',
                              style: AppTextStyles.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom control panel (40%) ──
          OnboardingBottomPanel(
            panelHeight: panelHeight,
            knobSize: knobSize,
            bottomPad: bottomPad,
            isRecording: _isRecording,
            talkEnabled: _talkEnabled,
            talkAnimationEnabled: _talkAnimationEnabled,
            onTalkTap: _onTalkTap,
            title: 'Catching Your Vibe',
            subtitle: 'Tap Talk to start.',
            pageCount: 5,
            activeIndex: 0,
          ),
        ],
      ),
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.knobCenter,
        border: Border.all(color: AppColors.knobOuter, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(AppAssets.appIcon, fit: BoxFit.contain),
      ),
    );
  }
}
