import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/services/firebase_auth_service.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class SignInViewModel extends BaseViewModel {

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  // -------------- Services [END] --------------- //

  // -------------- Models [START] --------------- //
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _signInButtonFocus = new FocusNode();
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  String _email = '';
  String _password = '';
  String _error = '';
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  FirebaseAuthService get authService => _authService;
  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get emailFocus => _emailFocus;
  FocusNode get passwordFocus => _passwordFocus;
  FocusNode get signInButtonFocus => _signInButtonFocus;

  String get email => _email;
  String get password => _password;
  String get error => _error;

  bool get showErrorDialog => error.isNotEmpty;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  void setEmail(String email) => _email = email;
  void setPassword(String password) => _password = password;
  void setError(String error) => _error = error;

  void showRegisterView() {
    // ToDo - Call parent to change its child Widget.
  }

  Future<dynamic> signInWithEmailAndPassword() async {
    if (formKey.currentState.validate()) {
      setBusy(true);
      await _authService.signInWithEmailAndPassword(email, password).catchError((error) => setError(error));
      setBusy(false);
    }
  }

  Future<dynamic> signInWithGoogle() async {
    setBusy(true);
    await _authService.signInWithGoogle().catchError((error) => setError(error));
    setBusy(false);
  }
  // -------------- Logic [START] --------------- //

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    signInButtonFocus.dispose();
    super.dispose();
  }

}
