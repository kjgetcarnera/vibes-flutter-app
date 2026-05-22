import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class AppIconBadge extends StatefulWidget {
  const AppIconBadge({super.key, this.size = 52, this.isSpeaking = false});

  final double size;
  final bool isSpeaking;

  @override
  State<AppIconBadge> createState() => _AppIconBadgeState();
}

class _AppIconBadgeState extends State<AppIconBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isSpeaking) _rotationController.repeat();
  }

  @override
  void didUpdateWidget(AppIconBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking && !oldWidget.isSpeaking) {
      _rotationController.repeat();
    } else if (!widget.isSpeaking && oldWidget.isSpeaking) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: widget.size,
      height: widget.size,
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

    if (!widget.isSpeaking) return badge;

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (_, child) => Transform.rotate(
        angle: _rotationController.value * 2 * pi,
        child: child,
      ),
      child: badge,
    );
  }
}
