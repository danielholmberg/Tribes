import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/services/firebase_auth_service.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class RegisterViewModel extends BaseViewModel {

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = FirebaseAuthService();
  // -------------- Services [END] --------------- //

  // -------------- Models [START] --------------- //
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _registerButtonFocus = new FocusNode();
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  String _name = '';
  String _email = '';
  String _password = '';
  String _error = '';
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get nameFocus => _nameFocus;
  FocusNode get emailFocus => _emailFocus;
  FocusNode get passwordFocus => _passwordFocus;
  FocusNode get registerButtonFocus => _registerButtonFocus;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get error => _error; 
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  void setName(String name) => _name = name;
  void setEmail(String email) => _email = email;
  void setPassword(String password) => _password = password;
  void setError(String error) => _error = error;

  Future registerWithEmailAndPassword() async {
    if (_formKey.currentState.validate()) {
      setBusy(true);
      await _authService.registerWithEmailAndPassword(_email, _password, _name).catchError((error) => setError(error));
      setBusy(false);
    }
  }
  // -------------- Logic [END] --------------- //
  
  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    registerButtonFocus.dispose();
    super.dispose();
  }
}