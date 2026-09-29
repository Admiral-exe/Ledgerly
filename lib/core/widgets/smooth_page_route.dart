import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SmoothTransitionType transitionType;

  SmoothPageRoute({
    required this.page,
    this.transitionType = SmoothTransitionType.slideRight,
    super.settings,
    Duration duration = const Duration(milliseconds: 380),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case SmoothTransitionType.fadeThrough:
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                    child: child,
                  ),
                );

              case SmoothTransitionType.slideUp:
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                );
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(
                    opacity: curved,
                    child: child,
                  ),
                );

              case SmoothTransitionType.slideRight:
              default:
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(
                    opacity: curved,
                    child: child,
                  ),
                );
            }
          },
        );
}

enum SmoothTransitionType {
  slideRight,
  slideUp,
  fadeThrough,
}
