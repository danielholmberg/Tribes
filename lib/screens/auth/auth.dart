import 'package:flutter/material.dart';
import 'package:tribes/screens/auth/widgets/Register.dart';
import 'package:tribes/screens/auth/widgets/SignIn.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {

  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn 
      ? SignIn(toggleView: toggleView) 
      : Register(toggleView: toggleView);
  }
}