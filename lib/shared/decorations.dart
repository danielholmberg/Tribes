library Decorations;

import 'package:flutter/material.dart';

const emailInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  suffixIcon: Icon(Icons.email),
  hintStyle: TextStyle(color: Colors.grey),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  )
);

const passwordInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  suffixIcon: Icon(Icons.lock),
  hintStyle: TextStyle(color: Colors.grey),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  )
);