import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

enum CustomPageTransitionType {
  postDetails,
  tribeRoom,
  newPost,
  newTribe,
  joinTribe,
}

class CustomPageTransition<T> extends PageRouteBuilder<T> {
  final CustomPageTransitionType type;
  final Widget child;
  final Curve curve;
  final Duration duration;

  CustomPageTransition({
    Key key,
    @required this.type,
    @required this.child,
    this.curve = Curves.linear,
    this.duration = Constants.pageTransition600,
    RouteSettings settings,
  }) : super(
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return child;
    },
    transitionDuration: duration,
    settings: settings,
    transitionsBuilder: (BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
        switch(type) {
          case CustomPageTransitionType.postDetails: 
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.00,
                  0.50,
                  curve: Curves.easeOutQuad,
                ),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          case CustomPageTransitionType.tribeRoom: 
            return FadeTransition(
              opacity: animation, 
              child: child,
            );
          case CustomPageTransitionType.newPost: 
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.00,
                  0.50,
                  curve: Curves.easeOutQuad,
                ),
              ),
              child: child
            );
          case CustomPageTransitionType.newTribe:
            return ScaleTransition(
              alignment: Alignment.topRight,
              scale: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.00,
                  0.50,
                  curve: Curves.easeOutQuad,
                ),
              ),
              child: FadeTransition(opacity: animation, child: child)
            );
          case CustomPageTransitionType.joinTribe:
            return FadeTransition(opacity: animation, child: child);
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      }
    );
}
