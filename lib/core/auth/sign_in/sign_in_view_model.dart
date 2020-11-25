import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/services/firebase/auth_service.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class SignInViewModel extends BaseViewModel {
  final AuthService _authService = locator<AuthService>();
  final DialogService _dialogService = locator<DialogService>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _signInButtonFocus = new FocusNode();

  BuildContext _context;
  String _email = '';
  String _password = '';
  String _error = '';

  AuthService get authService => _authService;
  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get emailFocus => _emailFocus;
  FocusNode get passwordFocus => _passwordFocus;
  FocusNode get signInButtonFocus => _signInButtonFocus;

  String get email => _email;
  String get password => _password;
  String get currentError => _error;

  List<TextInputFormatter> get inputFormatters =>
      [new FilteringTextInputFormatter.deny(new RegExp('[\\ ]'))];

  initialise(BuildContext context) {
    _context = context;
  }

  void setEmail(String email) => _email = email;
  void setPassword(String password) => _password = password;

  void showRegisterView() {
    // ToDo - Call parent to change its child Widget.
  }

  Future<dynamic> signInWithEmailAndPassword() async {
    if (formKey.currentState.validate()) {
      setBusy(true);
      await _authService
          .signInWithEmailAndPassword(email, password)
          .catchError((error) => _error);
      setBusy(false);
    }
  }

  Future<dynamic> signInWithGoogle() async {
    setBusy(true);
    await _authService
        .signInWithGoogle()
        .catchError((error) => setError(error));
    setBusy(false);
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    signInButtonFocus.dispose();
    super.dispose();
  }

  @override
  void setError(error) {
    _error = error.toString();
    super.setError(error);
  }

  @override
  bool get hasError => _error.isNotEmpty;

  Future showErrorDialog() async {
    await _dialogService.showDialog(
      title: 'Sign in error',
      description: _error,
    );
    _error = '';
    notifyListeners();
  }

  String emailValidator(String value) {
    return value.toString().trim().isEmpty
        ? 'Oops, you forgot to enter your email'
        : null;
  }

  void onEmailSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_passwordFocus);
  }

  String passwordValidator(String value) {
    return value.trim().isEmpty || value.length < 6
        ? 'Password must be 6 characters or more'
        : null;
  }

  void onPasswordSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_signInButtonFocus);
  }

  void onForgotPassword() {
    Fluttertoast.showToast(
      msg: 'Coming soon!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
