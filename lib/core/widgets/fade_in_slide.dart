import 'package:flutter/material.dart';

class FadeInSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double slideOffset;

  const FadeInSlide({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = 16.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
