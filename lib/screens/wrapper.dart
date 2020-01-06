import 'package:flutter/material.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/auth/auth.dart';
import 'package:provider/provider.dart';
import 'package:tribes/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user != null ? Home() : Auth();
  }
}