import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/wrapper.dart';
import 'package:tribes/services/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.cyan[100],
          accentColor: Colors.pink[400],
          iconTheme: IconThemeData(color: Colors.white, opacity: 1.0, size: 24.0),
          fontFamily: 'TribesRounded',
          textTheme: TextTheme(
              headline: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
              title: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              body1: TextStyle(fontSize: 12.0),
              button: TextStyle(color: Colors.white),
          ),
        ),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}