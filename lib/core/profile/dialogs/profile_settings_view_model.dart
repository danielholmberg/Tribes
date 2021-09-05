import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/auth_service.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class ProfileSettingsViewModel extends ReactiveViewModel {
  final AuthService _authService = locator<AuthService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _usernameFocus = new FocusNode();
  final FocusNode _infoFocus = new FocusNode();
  final FocusNode _saveButtonFocus = new FocusNode();

  BuildContext _context;
  ThemeData _themeData;

  String _name;
  String _username;
  String _info;
  String _error = '';

  String _originalName;
  String _originalUsername;
  String _originalInfo;

  MyUser get currentUser => _databaseService.currentUserData;
  bool get edited =>
      _originalName != _name ||
      _originalUsername != _username ||
      _originalInfo != _info;

  String get username => _username;
  String get currentError => _error;

  GlobalKey<FormState> get formKey => _formKey;

  String get initialName => _name ?? currentUser.name;
  String get initalUsername => _username ?? currentUser.username;
  String get initialInfo => _info ?? currentUser.info;

  FocusNode get nameFocus => _nameFocus;
  FocusNode get usernameFocus => _usernameFocus;
  FocusNode get infoFocus => _infoFocus;

  List<TextInputFormatter> get inputFormatters => [
        new FilteringTextInputFormatter.deny(new RegExp('[\\ ]')),
      ];

  void initState(BuildContext context, ThemeData themeData) {
    _context = context;
    _themeData = themeData;

    _originalName = currentUser.name;
    _originalUsername = currentUser.username;
    _originalInfo = currentUser.info;
    _name = _originalName;
    _username = _originalUsername;
    _info = _originalInfo;
  }

  void onSignOutConfirmed() {
    _navigationService.popUntil((route) => route.isFirst);
    _authService.signOut();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _usernameFocus.dispose();
    _infoFocus.dispose();
    _saveButtonFocus.dispose();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_authService, _databaseService];

  onSaveSettings() async {
    if (_formKey.currentState.validate()) {
      print('Updating profile information...');
      setBusy(true);
      bool available = true;

      if (_username != _originalUsername) {
        available =
            await DatabaseService().checkUsernameAvailability(_username);
      }

      if (available) {
        await DatabaseService().updateUserData(
            currentUser.id,
            _name ?? currentUser.name,
            _username ?? currentUser.username,
            currentUser.email,
            _info ?? currentUser.info,
            currentUser.lat,
            currentUser.lng);

        ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
          content: Text('Profile info saved'),
          duration: Duration(milliseconds: 500),
        ));

        _originalName = _name;
        _originalUsername = _username;
        _originalInfo = _info;
      } else {
        _showUnavailableUsernameDialog();
      }
      setBusy(false);
    }
  }

  void _showUnavailableUsernameDialog() {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(Constants.dialogCornerRadius))),
        title: Text(
          'Username already in use',
          style: TextStyle(
            fontFamily: 'TribesRounded',
            fontWeight: Constants.defaultDialogTitleFontWeight,
            fontSize: Constants.defaultDialogTitleFontSize,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(
                color: _themeData.primaryColor,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _navigationService.back,
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: RichText(
                maxLines: null,
                softWrap: true,
                text: TextSpan(
                  text: 'The username ',
                  style: _themeData.textTheme.bodyText2,
                  children: <TextSpan>[
                    TextSpan(
                      text: _username,
                      style: _themeData.textTheme.bodyText2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ' is already in use by a fellow Tribe explorer, please try another one.',
                      style: _themeData.textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onNameChanged(String value) {
    _name = value;
    notifyListeners();
  }

  void onUsernameChanged(String value) {
    _username = value;
    notifyListeners();
  }

  void onInfoChanged(String value) {
    _info = value;
    notifyListeners();
  }

  String nameValidator(String value) {
    return value.isEmpty ? 'Please add your name' : null;
  }

  String usernameValidator(value) {
    return value.isEmpty ? 'Please enter a username' : null;
  }

  onNameSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_usernameFocus);
  }

  onUsernameSubmitted(String value) async {
    bool available = await DatabaseService().updateUsername(
      username,
    );

    if (!available && username != _originalUsername) {
      _showUnavailableUsernameDialog();
    }
  }

  onInfoSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_saveButtonFocus);
  }

  @override
  bool get hasError => _error.isNotEmpty;
}
