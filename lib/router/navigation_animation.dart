import 'package:flutter/widgets.dart';

class NavigationAnimation extends PageRouteBuilder {
  final Widget page;

  NavigationAnimation({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
      );
}
