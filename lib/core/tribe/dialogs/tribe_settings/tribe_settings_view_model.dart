import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeSettingsViewModel extends ReactiveViewModel {
  final Function(Tribe) onSave;
  TribeSettingsViewModel({@required this.onSave});

  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _descFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();

  bool _firstToggle = true;

  BuildContext _context;
  Tribe _tribe;

  String _name;
  String _desc;
  Color _tribeColor;
  String _password;
  String _imageURL;
  bool _secret;
  String _error = '';

  String _originalName;
  String _originalDesc;
  Color _originalTribeColor;
  String _originalPassword;
  bool _originalSecret;

  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get nameFocus => _nameFocus;
  FocusNode get descFocus => _descFocus;
  FocusNode get passwordFocus => _passwordFocus;

  bool get firstToggle => _firstToggle;
  bool get edited =>
      _originalName != _name ||
      _originalDesc != _desc ||
      _originalPassword != _password ||
      _originalTribeColor != _tribeColor ||
      _originalSecret != _secret;

  Tribe get tribe => _tribe;

  String get name => _name;
  String get desc => _desc;
  Color get tribeColor => _tribeColor;
  String get password => _password;
  String get imageURL => _imageURL;
  bool get secret => _secret;
  String get currentError => _error;

  String get originalName => _originalName;
  String get originalDesc => _originalDesc;
  Color get originalTribeColor => _originalTribeColor;
  String get originalPassword => _originalPassword;
  bool get originalSecret => _originalSecret;

  Color get currentTribeColor => _tribeColor != null
      ? _tribeColor
      : _tribe.color ?? Constants.primaryColor;

  Stream<Tribe> get tribeDetailsStream => _databaseService.tribe(_tribe.id);

  List<TextInputFormatter> get passwordInputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ];

  void initState({
    @required BuildContext context,
    @required Tribe tribe,
  }) {
    _context = context;
    _tribe = tribe;

    _originalName = tribe.name;
    _originalDesc = tribe.desc;
    _originalTribeColor = tribe.color;
    _originalPassword = tribe.password;
    _originalSecret = tribe.secret;

    _name = _originalName;
    _desc = _originalDesc;
    _tribeColor = _originalTribeColor;
    _password = _originalPassword;
    _secret = _originalSecret;
  }

  void back() {
    _navigationService.back();
  }

  String nameValidator(String value) {
    return value.isEmpty ? 'Please add a name' : null;
  }

  String passwordValidator(String value) {
    return value.length != 6 ? 'Password must be 6 digits' : null;
  }

  void onNameChanged(String value) {
    _name = value;
    notifyListeners();
  }

  void onDescChanged(String value) {
    _desc = value;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    notifyListeners();
  }

  void onNameSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_descFocus);
  }

  void changeColor(Color color) {
    _tribeColor = color;
    notifyListeners();
    back();
  }

  Future<void> onDeleteTribe() async {
    setBusy(true);
    try {
      await _databaseService.deleteTribe(_tribe.id);
      _navigationService.popUntil((route) => route.isFirst);
    } catch(error) {
      await _dialogService.showDialog(
        title: 'Failed to delete Tribe!',
        description: 'An error occurred trying to delete this Tribe, please try again later.',
      );
      _navigationService.back();
    }
    setBusy(false);
  }

  void setFirstToggle(bool value) {
    _firstToggle = value;
    notifyListeners();
  }

  void toggleSecret() {
    _secret = !_secret;
    notifyListeners();
  }

  bool onDeleteTribeCheckChanged(String value) {
    if (value == _tribe.name) {
      return false;
    } else {
      return true;
    }
  }

  void onSaveTribeSettings() {
    if (_formKey.currentState.validate()) {
      print('Updating Tribe information...');
      setBusy(true);

      _databaseService.updateTribeData(
        _tribe.id,
        name ?? _originalName,
        desc ?? _originalDesc,
        tribeColor != null
            ? tribeColor.value.toRadixString(16)
            : _originalTribeColor.value.toRadixString(16) ??
                Constants.primaryColor.value.toRadixString(16),
        password ?? _originalPassword,
        imageURL,
        secret,
      );

      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
            'Tribe settings saved!',
            style: TextStyle(
              fontFamily: 'TribesRounded',
            ),
          ),
        ),
      );

      setBusy(false);

      _originalName = _name;
      _originalDesc = _desc;
      _originalTribeColor = _tribeColor;
      _originalPassword = _password;
      _originalSecret = _secret;

      onSave(
        _tribe.copyWith(
          name: _name,
          desc: _desc,
          color: _tribeColor,
          password: _password,
          secret: _secret,
        ),
      );
    }
  }

  void setTribe(Tribe tribe) {
    _tribe = tribe;
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  @override
  bool get hasError => _error.isNotEmpty;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
