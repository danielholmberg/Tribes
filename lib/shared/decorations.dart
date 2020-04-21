library Decorations;

import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

const signInInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'TribesRounded'),
  errorStyle: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontStyle: FontStyle.italic),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.inputEnabledColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryColor, width: 2.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
);

const registerInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  counterStyle: TextStyle(color: Colors.white, fontFamily: 'TribesRounded'),
  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'TribesRounded'),
  errorStyle: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontStyle: FontStyle.italic),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.inputEnabledColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryColor, width: 2.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
);

const postInput = InputDecoration(
  border: InputBorder.none,
  fillColor: Colors.transparent,
  filled: true,
  isDense: true,
  contentPadding: EdgeInsets.zero,
  hintStyle: TextStyle(fontFamily: 'TribesRounded'),
  counterStyle: TextStyle(color: Constants.inputCounterColor, fontFamily: 'TribesTrounded'),
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
);

const newTribeInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  isDense: true,
  hintText: 'Content',
  hintStyle: TextStyle(fontFamily: 'TribesRounded'),
  counterStyle: TextStyle(color: Constants.inputCounterColor, fontFamily: 'TribesTrounded'),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputEnabledColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputFocusColor, width: 2.0),
  )
);

const profileSettingsInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelStyle: TextStyle(color: Constants.inputLabelColor, fontFamily: 'TribeRounded'),
  hintStyle: TextStyle(fontFamily: 'TribesRounded'),
  counterStyle: TextStyle(color: Constants.inputCounterColor, fontFamily: 'TribesRounded'),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputEnabledColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputFocusColor, width: 2.0),
  )
);

const tribeDetailsInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelStyle: TextStyle(color: Constants.inputLabelColor, fontFamily: 'TribeRounded'),
  hintStyle: TextStyle(fontFamily: 'TribesRounded'),
  counterStyle: TextStyle(color: Constants.inputCounterColor, fontFamily: 'TribesRounded'),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputEnabledColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputFocusColor, width: 2.0),
  )
);

const tribeSettingsInput = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelStyle: TextStyle(color: Constants.inputLabelColor, fontFamily: 'TribeRounded'),
  hintStyle: TextStyle(fontFamily: 'TribesRounded'),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputEnabledColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.inputFocusColor, width: 2.0),
  )
);

const newTribesInput = InputDecoration(
  fillColor: Constants.backgroundColor,
  filled: true,
  labelStyle: TextStyle(color: Constants.tribesColor, fontFamily: 'TribeRounded'),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.backgroundColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.tribesColor, width: 2.0),
  )
);

const tribePasswordInput = InputDecoration(
  fillColor: Constants.backgroundColor,
  filled: true,
  hintStyle: TextStyle(color: Colors.black26, fontFamily: 'TribeRounded'),
  contentPadding: EdgeInsets.zero,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Colors.black26, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Constants.primaryColor, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  )
);