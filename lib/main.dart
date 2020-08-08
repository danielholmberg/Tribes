import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tribes/core/auth/auth_view.dart';
import 'package:tribes/core/chat/chat_view.dart';
import 'package:tribes/core/foundation/foundation_view.dart';
import 'package:tribes/core/home/home_view.dart';
import 'package:tribes/core/map/map_view.dart';
import 'package:tribes/core/profile/profile_view.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase_auth_service.dart';
import 'package:tribes/services/navigation_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // Theme Data
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _themeData(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      primaryColor: Constants.primaryColor,
      accentColor: Constants.accentColor,
      backgroundColor: Constants.backgroundColor,
      buttonColor: Constants.buttonColor,
      appBarTheme: AppBarTheme(
        color: Constants.appBarColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.pink,
        elevation: Constants.floatingActionButtonElevation,
      ),
      iconTheme: IconThemeData(color: Colors.white, opacity: 1.0, size: 24.0),
      fontFamily: 'TribesRounded',
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => _themeData(brightness),
      themedWidgetBuilder: (context, theme) {
        return StreamProvider<User>.value(
          value: locator<FirebaseAuthService>().user,
          builder: (context, snapshot) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: locator<NavigationService>().navigationKey,
              initialRoute: '/', // Start the app with the "/" named route. 
                routes: {
                  '/': (context) => AuthView(),
                  FoundationView.routeName: (context) => FoundationView(),
                  HomeView.routeName: (context) => new FoundationView(),
                  MapView.routeName: (context) => new FoundationView(),
                  ChatView.routeName: (context) => new FoundationView(),
                  ProfileView.routeName: (context) => new FoundationView(),
                },
            );
          }
        );
      },
    );
  }
}
