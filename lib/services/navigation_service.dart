import 'package:flutter/material.dart';
import 'package:tribes/core/auth/auth_view.dart';
import 'package:tribes/core/chat/chat_view.dart';
import 'package:tribes/core/home/home_view.dart';
import 'package:tribes/core/map/map_view.dart';
import 'package:tribes/core/profile/profile_view.dart';
import 'package:tribes/shared/constants.dart';

class NavigationService {
  GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  void pop() {
    return _navigationKey.currentState.pop();
  }

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return _navigationKey.currentState
        .pushNamed(routeName, arguments: arguments);
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AuthViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: AuthView(),
      );
    case HomeViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: HomeView(),
      );
    case ProfileViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ProfileView(),
      );
    case MapViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: MapView(),
      );
    case ChatViewRoute:
      return _getPageRoute(
        routeName: settings.name,
        viewToShow: ChatView(),
      );
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

PageRoute _getPageRoute({String routeName, Widget viewToShow}) {
  return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (_) => viewToShow);
}