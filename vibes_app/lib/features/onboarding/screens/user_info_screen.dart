import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_primary_button.dart';

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
    final bottomPad = mq.padding.bottom;
    final topPad = mq.padding.top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
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
                          child: AppIconBadge(),
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
                        AppInputField(
                          label: 'FIRST NAME',
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          error: _firstNameError,
                          hintText: 'Your name',
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _ageFocus.requestFocus(),
                        ),
                        const SizedBox(height: 20),
                        AppInputField(
                          label: 'AGE',
                          controller: _ageController,
                          focusNode: _ageFocus,
                          error: _ageError,
                          hintText: 'Your age',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textInputAction: TextInputAction.done,
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
                child: AppPrimaryButton(label: 'NEXT', onTap: _onNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
