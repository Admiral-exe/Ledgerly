import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class AnimatedCurrencyCounter extends StatelessWidget {
  final double amount;
  final TextStyle style;
  final Duration duration;
  final bool showDecimals;

  const AnimatedCurrencyCounter({
    super.key,
    required this.amount,
    required this.style,
    this.duration = const Duration(milliseconds: 950),
    this.showDecimals = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          Formatters.currency(value, showDecimals: showDecimals),
          style: style,
        );
      },
    );
  }
}
