library Decorations;

import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

const signInInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'TribesRounded'),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.accentColor, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.errorColor, width: 2.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.errorColor, width: 2.0),
  ),
);

const registerInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'TribesRounded'),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.accentColor, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.errorColor, width: 2.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.errorColor, width: 2.0),
  ),
);

const postTitleInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelText: 'Title',
  labelStyle: TextStyle(color: Constants.postInputFocusColor),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.postBackgroundColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.postInputFocusColor, width: 2.0),
  )
);

const postContentInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelText: 'Content',
  labelStyle: TextStyle(color: Constants.postInputFocusColor),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.postBackgroundColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.postInputFocusColor, width: 2.0),
  )
);

const profileSettingsInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelStyle: TextStyle(color: Constants.postInputFocusColor),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.postBackgroundColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.postInputFocusColor, width: 2.0),
  )
);

const newTribesInput = InputDecoration(
  fillColor: Constants.backgroundColor,
  filled: true,
  labelStyle: TextStyle(color: Constants.tribesColor),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.backgroundColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.tribesColor, width: 2.0),
  )
);
