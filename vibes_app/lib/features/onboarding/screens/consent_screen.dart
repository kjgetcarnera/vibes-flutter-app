import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_icon_badge.dart';
import '../../../core/widgets/app_primary_button.dart';
import 'read_passage_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({
    super.key,
    required this.firstName,
    required this.age,
    this.latitude,
    this.longitude,
  });

  final String firstName;
  final int age;
  final double? latitude;
  final double? longitude;

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FlutterTts _tts = FlutterTts();
  bool _ttsDisposed = false;
  bool _isSpeaking = false;

  final List<bool> _checked = [false, false, false, false];

  bool get _allChecked => _checked.every((v) => v);
  int get _checkedCount => _checked.where((v) => v).length;

  static const _items = [
    _ConsentItem(
      title: 'Your voice trains MANTRA',
      body:
          'Your recording helps build our voice biomarker model for brain health and cognitive wellness — the one that makes neurowellness accessible to everyone.',
    ),
    _ConsentItem(
      title: 'Research & community good',
      body:
          'Your audio helps make brain health awareness and prevention possible for more people — from Boston to Belize. That\'s the mission.',
    ),
    _ConsentItem(
      title: 'Your voice is private',
      body:
          'We don\'t sell it. We don\'t share it. Stored without personal identifiers and never attributed to your identity.',
    ),
    _ConsentItem(
      title: 'This is not medical care',
      body:
          'This is research and wellness exploration. No diagnosis, no medical advice, no individual clinical results.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 800), _speakIntro);
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
    await _tts.speak(
      'Before we begin. tick each box to confirm you understand.',
    );
  }

  @override
  void dispose() {
    _ttsDisposed = true;
    _tts.stop();
    _fadeController.dispose();
    super.dispose();
  }

  void _openWebSheet(BuildContext context, String title, String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

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
        builder: (_, __) => Column(
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
                    shaderCallback: (bounds) =>
                        AppColors.accentGradient2.createShader(bounds),
                    child: Text(
                      title,
                      style: AppTextStyles.headingBold.copyWith(
                        color: Colors.white,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // ── Top nav bar ──
              Container(
                padding: EdgeInsets.only(
                  top: topPad + 8,
                  left: 20,
                  right: 20,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withAlpha(15), width: 1),
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
                          border: Border.all(color: AppColors.knobOuter, width: 1),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    AppIconBadge(isSpeaking: _isSpeaking),
                  ],
                ),
              ),
              Expanded(
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
                      // Label
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.accentGradient2.createShader(bounds),
                        child: Text(
                          'BEFORE WE BEGIN',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Headline
                      Text(
                        'tick each box to confirm you understand.',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sub-copy
                      Text(
                        'your voice is powerful. before you share it, i want to make sure you know exactly how we use it — and why it matters.',
                        style: AppTextStyles.bodyMono.copyWith(height: 1.7),
                      ),
                      const SizedBox(height: 28),
                      // Consent cards
                      ...List.generate(_items.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ConsentCard(
                            item: _items[i],
                            checked: _checked[i],
                            onTap: () =>
                                setState(() => _checked[i] = !_checked[i]),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      // Footer legal note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2026),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'by continuing you confirm you are 18+ and consent to the above. read our full ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _openWebSheet(
                                    context,
                                    'Privacy Policy',
                                    'https://www.privacypolicies.com/live/sample',
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => AppColors
                                        .accentGradient2
                                        .createShader(bounds),
                                    child: Text(
                                      'privacy policy',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _openWebSheet(
                                    context,
                                    'Terms of Use',
                                    'https://www.termsofusegenerator.net/live.php?token=sample',
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => AppColors
                                        .accentGradient2
                                        .createShader(bounds),
                                    child: Text(
                                      'terms of use',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Progress dots + count
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_items.length, (i) {
                              final active = _checked[i];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: active ? 10 : 8,
                                height: active ? 10 : 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: active
                                      ? AppColors.accentGradient2
                                      : null,
                                  color: active
                                      ? null
                                      : AppColors.indicatorInactive,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_checkedCount of ${_items.length} confirmed',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // CTA button
              Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
                child: SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: 'begin my vibe check →',
                    onTap: _allChecked
                        ? () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ReadPassageScreen(
                                firstName: widget.firstName,
                                age: widget.age,
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                              ),
                            ),
                          )
                        : () {},
                    enabled: _allChecked,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentItem {
  const _ConsentItem({required this.title, required this.body});
  final String title;
  final String body;
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.item,
    required this.checked,
    required this.onTap,
  });

  final _ConsentItem item;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFF1A2620) : const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: checked
                ? AppColors.accentGreen2.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: checked ? AppColors.accentGradient2 : null,
                color: checked ? null : Colors.transparent,
                border: checked
                    ? null
                    : Border.all(color: AppColors.textMuted, width: 1.5),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 15, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMono.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.body,
                    style: AppTextStyles.bodyMono.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
