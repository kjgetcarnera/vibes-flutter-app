import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

class KnobWidget extends StatefulWidget {
  const KnobWidget({
    super.key,
    this.size = 160,
    this.isSpinning = false,
  });

  final double size;
  final bool isSpinning;

  @override
  State<KnobWidget> createState() => _KnobWidgetState();
}

class _KnobWidgetState extends State<KnobWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isSpinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(KnobWidget old) {
    super.didUpdateWidget(old);
    if (widget.isSpinning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSpinning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Image.asset(
            AppAssets.recoderIcon,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
