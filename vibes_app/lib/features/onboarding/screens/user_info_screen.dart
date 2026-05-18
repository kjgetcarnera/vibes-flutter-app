import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/onboarding_bottom_panel.dart';

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

  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _firstNameFocus = FocusNode();
  final _ageFocus = FocusNode();

  String? _firstNameError;
  String? _ageError;

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
  }

  @override
  void dispose() {
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

    final payload = {
      'firstName': _firstNameController.text.trim(),
      'age': int.parse(_ageController.text.trim()),
    };

    // ignore: avoid_print
    print('[UserInfoScreen] payload: $payload');
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

    final panelHeight = screenHeight * 0.40;
    final knobSize = (screenWidth * 0.38).clamp(120.0, 185.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // ── Scrollable content (60%) ──
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
                        // App icon badge
                        Align(
                          alignment: Alignment.centerRight,
                          child: _AppIconBadge(),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Tell us about\nyourself.',
                          style: AppTextStyles.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Just two things to get started.',
                          style: AppTextStyles.bodyMono,
                        ),
                        const SizedBox(height: 36),

                        // First name field
                        _InputField(
                          label: 'FIRST NAME',
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          error: _firstNameError,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _ageFocus.requestFocus(),
                        ),
                        const SizedBox(height: 20),

                        // Age field
                        _InputField(
                          label: 'AGE',
                          controller: _ageController,
                          focusNode: _ageFocus,
                          error: _ageError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onNext(),
                        ),
                        const SizedBox(height: 36),

                        // Next button
                        SizedBox(
                          width: double.infinity,
                          child: _NextButton(onTap: _onNext),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom control panel (40%) ──
            OnboardingBottomPanel(
              panelHeight: panelHeight,
              knobSize: knobSize,
              bottomPad: bottomPad,
              isRecording: false,
              talkEnabled: false,
              talkAnimationEnabled: false,
              onTalkTap: () {},
              title: 'About You',
              subtitle: 'Fill in your details.',
              pageCount: 5,
              activeIndex: 1,
              onClose: () => Navigator.maybePop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Input field
// ─────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.error,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          style: AppTextStyles.displayLarge.copyWith(fontSize: 20),
          cursorColor: AppColors.accentCyan,
          decoration: InputDecoration(
            hintText: label == 'FIRST NAME' ? 'Your name' : 'Your age',
            hintStyle: AppTextStyles.bodyMono.copyWith(
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.knobCenter,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.redAccent.withAlpha(180)
                    : AppColors.knobOuter,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : AppColors.accentCyan,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: AppTextStyles.caption.copyWith(
              color: Colors.redAccent,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Next button
// ─────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          'NEXT',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// App icon badge
// ─────────────────────────────────────────────────────────────
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
