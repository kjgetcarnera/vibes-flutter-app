import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/app_auth_field.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/location_fetcher.dart';
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

  final FlutterTts _tts = FlutterTts();
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
    await _tts.setLanguage('en-US');
    if (_ttsDisposed) return;
    await _tts.setSpeechRate(0.35);
    if (_ttsDisposed) return;
    _tts.setStartHandler(() {
      if (!_ttsDisposed) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (!_ttsDisposed) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (!_ttsDisposed) setState(() => _isSpeaking = false);
    });
    // await _tts.speak('Tell us about yourself. Just two things to get started.');
    await _tts.speak(
      "Hey - I've been waiting to hear your voice - Just two things to get started.",
    );
  }

  @override
  void dispose() {
    _ttsDisposed = true;
    _tts.stop();
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
      ..loadRequest(Uri.parse('https://www.privacypolicies.com/live/sample'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF15171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ShaderMask(
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(child: WebViewWidget(controller: controller)),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConsentScreen(
          firstName: _firstNameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Main headline
                        Text(
                          "Hey, i've been waiting to hear\nyour voice.",
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 32,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Intro body copy
                        Text(
                          "i'm VAIA — your frequency guide. speak, get your vibe score, find your sound. one loop at a time.",
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
                                text: 'brain health is a birthright. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'your voice helps make it real for everyone — from Boston to Belize.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Feature cards row
                        Row(
                          children: [
                            _FeatureCard(
                              title: 'speak',
                              subtitle: 'read a passage',
                            ),
                            const SizedBox(width: 10),
                            _FeatureCard(title: 'score', subtitle: 'BRS + Hz'),
                            const SizedBox(width: 10),
                            _FeatureCard(
                              title: 'shift',
                              subtitle: 'listen + rate',
                            ),
                          ],
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
                          hint: 'your name',
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
                          hint: 'your age',
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
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: '🔒 '),
                              const TextSpan(
                                text:
                                    'your voice is private — no identity attached, never sold. ',
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
                                      'privacy policy →',
                                      style: AppTextStyles.caption.copyWith(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMono.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
