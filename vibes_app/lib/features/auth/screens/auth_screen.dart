import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../onboarding/screens/user_info_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignUp = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _apiError;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailOk = email.isNotEmpty && email.contains('@');
    final passwordOk = password.length >= 6;
    final confirmOk = !_isSignUp || _confirmPasswordController.text == password;
    return emailOk && passwordOk && confirmOk;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    // Rebuild when any field changes so button enables/disables live
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(bool signUp) {
    if (_isSignUp == signUp) return;
    setState(() {
      _isSignUp = signUp;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
    _fadeController.forward(from: 0);
  }

  bool _validate() {
    bool valid = true;

    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
      valid = false;
    } else {
      setState(() => _emailError = null);
    }

    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() => _passwordError = 'Minimum 6 characters');
      valid = false;
    } else {
      setState(() => _passwordError = null);
    }

    if (_isSignUp) {
      if (_confirmPasswordController.text != password) {
        setState(() => _confirmPasswordError = 'Passwords do not match');
        valid = false;
      } else {
        setState(() => _confirmPasswordError = null);
      }
    }

    return valid;
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      if (_isSignUp) {
        await AuthApiService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await AuthApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const UserInfoScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _apiError = e.message);
    } catch (_) {
      setState(
        () => _apiError = 'Network error. Please check your connection.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            // ── Top logo area ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPad + 24,
                  left: 28,
                  bottom: 30,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _LogoRow(),
                ),
              ),
            ),

            // ── Bottom panel ──
            _AuthPanel(
              isSignUp: _isSignUp,
              fadeAnimation: _fadeAnimation,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              showPassword: _showPassword,
              showConfirmPassword: _showConfirmPassword,
              emailError: _emailError,
              passwordError: _passwordError,
              confirmPasswordError: _confirmPasswordError,
              apiError: _apiError,
              isLoading: _isLoading,
              bottomPad: bottomPad,
              onToggleMode: _switchMode,
              onTogglePassword: () =>
                  setState(() => _showPassword = !_showPassword),
              onToggleConfirmPassword: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              onEmailChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
                if (_apiError != null) setState(() => _apiError = null);
              },
              onPasswordChanged: (_) {
                if (_passwordError != null)
                  setState(() => _passwordError = null);
                if (_apiError != null) setState(() => _apiError = null);
              },
              onConfirmPasswordChanged: (_) {
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
              isFormValid: _isFormValid && !_isLoading,
              onContinue: _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logo row
// ─────────────────────────────────────────────────────────────
class _LogoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.splash, width: 180, fit: BoxFit.contain);
  }
}

// ─────────────────────────────────────────────────────────────
// Auth panel
// ─────────────────────────────────────────────────────────────
class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.isSignUp,
    required this.fadeAnimation,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.bottomPad,
    required this.onToggleMode,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.isFormValid,
    required this.onContinue,
    required this.isLoading,
    this.apiError,
  });

  final bool isSignUp;
  final Animation<double> fadeAnimation;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showPassword;
  final bool showConfirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final double bottomPad;
  final void Function(bool) onToggleMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final bool isFormValid;
  final Future<void> Function() onContinue;
  final bool isLoading;
  final String? apiError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0F12),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 28, 24, bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle pill
          _TogglePill(isSignUp: isSignUp, onToggle: onToggleMode),
          const SizedBox(height: 30),

          // Fields animate when switching
          FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              children: [
                // Email
                _AuthField(
                  hint: 'Email address',
                  prefixIcon: Icons.mail_outline,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  error: emailError,
                  onChanged: onEmailChanged,
                ),
                const SizedBox(height: 20),

                // Password
                _AuthField(
                  hint: 'Password',
                  prefixIcon: Icons.lock_outline,
                  controller: passwordController,
                  obscure: !showPassword,
                  error: passwordError,
                  onChanged: onPasswordChanged,
                  suffix: GestureDetector(
                    onTap: onTogglePassword,
                    child: Icon(
                      showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.remove_red_eye_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),

                // Confirm Password (sign up only)
                if (isSignUp) ...[
                  const SizedBox(height: 20),
                  _AuthField(
                    hint: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    controller: confirmPasswordController,
                    obscure: !showConfirmPassword,
                    error: confirmPasswordError,
                    onChanged: onConfirmPasswordChanged,
                    suffix: GestureDetector(
                      onTap: onToggleConfirmPassword,
                      child: Icon(
                        showConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.remove_red_eye_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (apiError != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withAlpha(120)),
              ),
              child: Text(
                apiError!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.redAccent,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: isLoading
                ? const SizedBox(
                    height: 50,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00E5CC),
                        ),
                      ),
                    ),
                  )
                : AppPrimaryButton(
                    label: 'Continue',
                    onTap: onContinue,
                    enabled: isFormValid,
                    height: 50,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Toggle pill
// ─────────────────────────────────────────────────────────────
class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.isSignUp, required this.onToggle});

  final bool isSignUp;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.knobCenter,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Sign In',
            active: !isSignUp,
            onTap: () => onToggle(false),
          ),
          _Tab(label: 'Sign Up', active: isSignUp, onTap: () => onToggle(true)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: active ? AppColors.knobOuter : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.kamerikToggle.copyWith(
              color: active
                  ? const Color(0xFFFFFEFE)
                  : const Color(0xFFFFFEFE).withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Auth field
// ─────────────────────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.error,
    this.suffix,
    this.onChanged,
  });

  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? error;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.knobCenter,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? Colors.redAccent.withAlpha(180)
                  : AppColors.knobOuter,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(prefixIcon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  style: AppTextStyles.kamerikInput.copyWith(
                    color: const Color(0xFFFFFEFE),
                  ),
                  cursorColor: AppColors.accentCyan,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.kamerikInput,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (suffix != null) ...[suffix!, const SizedBox(width: 14)],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              error!,
              style: AppTextStyles.caption.copyWith(
                color: Colors.redAccent,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
