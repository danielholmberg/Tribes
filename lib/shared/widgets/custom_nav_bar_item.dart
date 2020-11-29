import 'package:flutter/material.dart';

class CustomNavBarItem {
  final String title;
  final IconData icon;
  final Widget avatar;

  CustomNavBarItem({
    @required this.icon,
    @required this.title,
    this.avatar,
  });
}