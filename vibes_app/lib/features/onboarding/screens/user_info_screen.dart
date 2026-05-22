import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/app_auth_field.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/location_fetcher.dart';
import 'read_passage_screen.dart';

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
    _speakIntro();
  }

  Future<void> _speakIntro() async {
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
    await _tts.speak('Tell us about yourself. Just two things to get started.');
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

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadPassageScreen(
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
            // Silently fetches location in background as soon as screen loads
            LocationFetcher(
              onResult: (result) => setState(() => _locationResult = result),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: topPad + 16,
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppIconBadge(isSpeaking: _isSpeaking),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tell us about\nyourself.',
                          style: AppTextStyles.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Just two things to get started.',
                          style: AppTextStyles.bodyMono,
                        ),
                        const SizedBox(height: 30),
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
                        const SizedBox(height: 20),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Next button pinned to bottom ──
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
              child: SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Next',
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
