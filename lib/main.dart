import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/wrapper.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/shared/constants.dart' as Constants;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // Theme Data
  ThemeData _themeData(Brightness _brightness) {
    return ThemeData(
        brightness: _brightness,
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
        textTheme: TextTheme(
            headline: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            title: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            subhead: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            body1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
            body2: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
            button: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold),
        ),
      );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => _themeData(brightness),
      themedWidgetBuilder: (context, theme) {
        return StreamProvider<User>.value(
          value: AuthService().user,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Wrapper(),
          ),
        );
      }
    );
  }
}
