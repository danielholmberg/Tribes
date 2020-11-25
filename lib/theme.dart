library theme;

import 'package:flutter/material.dart';

import 'shared/constants.dart' as Constants;

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
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

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
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
