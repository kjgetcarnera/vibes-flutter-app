import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TalkButton extends StatefulWidget {
  const TalkButton({
    super.key,
    this.onTap,

    /// Whether the button responds to taps.
    this.enabled = true,

    /// Whether the pulse animation runs. Has no effect when [enabled] is false.
    this.animationEnabled = true,
  });

  final VoidCallback? onTap;
  final bool enabled;
  final bool animationEnabled;

  @override
  State<TalkButton> createState() => _TalkButtonState();
}

class _TalkButtonState extends State<TalkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(TalkButton old) {
    super.didUpdateWidget(old);
    if (old.enabled != widget.enabled ||
        old.animationEnabled != widget.animationEnabled) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.enabled && widget.animationEnabled) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.enabled
        ? AppColors.accentCyan
        : AppColors.textMuted;
    final labelColor = widget.enabled
        ? AppColors.accentCyan
        : AppColors.textMuted;

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) =>
                Transform.scale(scale: _pulseAnim.value, child: child),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfacePanel,
                border: Border.all(
                  color: activeColor.withAlpha(widget.enabled ? 70 : 40),
                  width: 1,
                ),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: AppColors.accentCyan.withAlpha(45),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(Icons.graphic_eq, color: activeColor, size: 26),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'TALK',
            style: AppTextStyles.talkLabel.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}
