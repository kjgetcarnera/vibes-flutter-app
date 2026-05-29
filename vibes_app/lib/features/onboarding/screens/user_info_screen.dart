import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/app_auth_field.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/location_fetcher.dart';
import '../../../core/services/vibe_api_service.dart';
import 'consent_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AudioPlayer _tts = AudioPlayer();
  bool _ttsDisposed = false;
  bool _isSpeaking = false;

  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _firstNameFocus = FocusNode();
  final _ageFocus = FocusNode();

  String? _firstNameError;
  String? _ageError;

  LocationResult? _locationResult;

  bool get _isFormValid {
    final name = _firstNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    return name.length >= 2 && age != null && age >= 1 && age <= 120;
  }

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
    _firstNameController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
    Future.delayed(const Duration(milliseconds: 1000), _speakIntro);
  }

  Future<void> _speakIntro() async {
    if (_ttsDisposed) return;
    _tts.onPlayerStateChanged.listen((s) {
      if (_ttsDisposed) return;
      setState(() => _isSpeaking = s == PlayerState.playing);
    });
    await _tts.play(AssetSource('audio/first_audio.mp3'));
  }

  @override
  void dispose() {
    _ttsDisposed = true;
    _tts.dispose();
    _fadeController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _firstNameFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;

    final name = _firstNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _firstNameError = 'First name is required');
      valid = false;
    } else if (name.length < 2) {
      setState(() => _firstNameError = 'Must be at least 2 characters');
      valid = false;
    } else {
      setState(() => _firstNameError = null);
    }

    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);
    if (ageText.isEmpty) {
      setState(() => _ageError = 'Age is required');
      valid = false;
    } else if (age == null || age < 1 || age > 120) {
      setState(() => _ageError = 'Enter a valid age (1–120)');
      valid = false;
    } else {
      setState(() => _ageError = null);
    }

    return valid;
  }

  void _openPrivacyPolicy(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://getvibes.ai/privacypolicy'));

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF15171B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF15171B),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF2FE17A), Color(0xFF00FFF7)],
              ).createShader(bounds),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final name = _firstNameController.text.trim();
    final age = int.parse(_ageController.text.trim());

    // Fire-and-forget — user doesn't wait for this
    VibeApiService.updateUserProfile(name: name, age: age);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConsentScreen(
          firstName: name,
          age: age,
          latitude: _locationResult?.latitude,
          longitude: _locationResult?.longitude,
        ),
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
    final bottomPad = mq.padding.bottom;
    final topPad = mq.padding.top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            LocationFetcher(
              onResult: (result) => setState(() => _locationResult = result),
            ),
            // ── Sticky top nav bar ──
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
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
                      const SizedBox(width: 36),
                      AppIconBadge(isSpeaking: _isSpeaking),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // VAIA branding
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF2FE17A), Color(0xFF00FFF7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            'VAIA',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Main headline
                        Text(
                          "Hey, I've been waiting to hear\nyour voice.",
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 32,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Intro body copy
                        Text(
                          "I'm VAIA — your frequency guide. Speak, get your vibe score, find your sound. One loop at a time.",
                          style: AppTextStyles.bodyMono.copyWith(
                            height: 1.6,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Bold mission text
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMono.copyWith(
                              height: 1.6,
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Brain health is a birthright. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'Your voice helps make it real for everyone — from Boston to Belize.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Feature cards row
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _FeatureCard(
                                title: 'Speak',
                                subtitle: 'read a passage',
                              ),
                              const SizedBox(width: 10),
                              _FeatureCard(
                                title: 'Score',
                                subtitle: 'BRS + Hz',
                              ),
                              const SizedBox(width: 10),
                              _FeatureCard(
                                title: 'Shift',
                                subtitle: 'listen + rate',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Section label
                        Text(
                          'A BIT ABOUT YOU',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppAuthField(
                          hint: 'Your name',
                          prefixIcon: Icons.person_outline,
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          error: _firstNameError,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            setState(() => _firstNameError = null);
                          },
                          onSubmitted: (_) => _ageFocus.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        AppAuthField(
                          hint: 'Your age',
                          prefixIcon: Icons.cake_outlined,
                          controller: _ageController,
                          focusNode: _ageFocus,
                          error: _ageError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            setState(() => _ageError = null);
                          },
                          onSubmitted: (_) => _onNext(),
                        ),
                        const SizedBox(height: 20),
                        // Privacy note
                        Text.rich(
                          TextSpan(
                            style: AppTextStyles.bodyMono.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: '🔒 '),
                              const TextSpan(
                                text:
                                    'Your voice is private — no identity attached, never sold. ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _openPrivacyPolicy(context),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFF2FE17A),
                                            Color(0xFF00FFF7),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(bounds),
                                    child: Text(
                                      'Privacy Policy →',
                                      style: AppTextStyles.bodyMono.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Button pinned to bottom
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
              child: SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: "Let's Hear It →",
                  onTap: _onNext,
                  enabled: _isFormValid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.kamerikToggle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.kamerikToggle.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
