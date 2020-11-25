import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/services/firebase/auth_service.dart';

class RegisterViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _registerButtonFocus = new FocusNode();

  BuildContext _context;
  String _name = '';
  String _email = '';
  String _password = '';
  String _error = '';

  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get nameFocus => _nameFocus;
  FocusNode get emailFocus => _emailFocus;
  FocusNode get passwordFocus => _passwordFocus;
  FocusNode get registerButtonFocus => _registerButtonFocus;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get currentError => _error;

  List<TextInputFormatter> get inputFormatters =>
      [new FilteringTextInputFormatter.deny(new RegExp('[\\ ]'))];

  initialise(BuildContext context) {
    _context = context;
  }

  void setName(String name) => _name = name;
  void setEmail(String email) => _email = email;
  void setPassword(String password) => _password = password;

  Future registerWithEmailAndPassword() async {
    if (_formKey.currentState.validate()) {
      setBusy(true);
      await _authService
          .registerWithEmailAndPassword(_email, _password, _name)
          .catchError((error) => setError(error));
      setBusy(false);
    }
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    registerButtonFocus.dispose();
    super.dispose();
  }

  @override
  void setError(error) {
    _error = error;
    super.setError(error);
  }

  String nameValidator(String value) {
    return value.toString().trim().isEmpty
        ? 'Oops, you forgot to enter your name'
        : null;
  }

  void onNameSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_emailFocus);
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
    FocusScope.of(_context).requestFocus(_registerButtonFocus);
  }
}
