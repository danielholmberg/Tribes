import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/base.dart';
import 'package:tribes/screens/base/chats/Chats.dart';
import 'package:tribes/screens/base/chats/widgets/TribeMessages.dart';
import 'package:tribes/screens/base/map/MyMap.dart';
import 'package:tribes/screens/base/profile/Profile.dart';
import 'package:tribes/screens/base/tribes/Tribes.dart';
import 'package:tribes/screens/wrapper.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/shared/constants.dart' as Constants;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  // Theme Data
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
            button: TextStyle(color: Constants.buttonIconColor, fontWeight: FontWeight.bold),
        ),
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
          value: AuthService().user,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/', // Start the app with the "/" named route. 
            routes: {
              '/': (context) => Wrapper(),
              Base.routeName: (context) => Base(),
              Tribes.routeName: (context) => new Base(tabIndex: 0),
              MyMap.routeName: (context) => new Base(tabIndex: 1),
              Chats.routeName: (context) => new Base(tabIndex: 2),
              Profile.routeName: (context) => new Base(tabIndex: 3),
            },
          ),
        );
      }
    );
  }
}
