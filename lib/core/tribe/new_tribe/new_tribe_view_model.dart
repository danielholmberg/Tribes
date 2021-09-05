import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';

class NewTribeViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _descFocus = new FocusNode();

  BuildContext _context;

  String _name = '';
  String _desc = '';
  Color _tribeColor;
  bool _isSecret = false;
  String _error = '';

  bool _firstToggle = true;

  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get nameFocus => _nameFocus;
  FocusNode get descFocus => _descFocus;

  String get currentUserId => _databaseService.currentUserData.id;

  String get name => _name;
  String get desc => _desc;
  Color get tribeColor => _tribeColor ?? Constants.primaryColor;
  bool get isSecret => _isSecret;
  String get currentError => _error;

  bool get firstToggle => _firstToggle;

  bool get edited =>
      _name.isNotEmpty || _desc.isNotEmpty || _isSecret || _tribeColor != null;

  void initState({BuildContext context}) {
    _context = context;
  }

  String nameValidator(String value) {
    return value.isEmpty ? 'Enter a name' : null;
  }

  String descValidator(String value) {
    return value.isEmpty ? 'Enter a description' : null;
  }

  void onNameChanged(String value) {
    _name = value;
    notifyListeners();
  }

  void onDescChanged(String value) {
    _desc = value;
    notifyListeners();
  }

  void onNameSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_descFocus);
  }

  void _changeColor(Color color) {
    _tribeColor = color;
    notifyListeners();
    _navigationService.back();
  }

  void onBackPress() {
    if (edited) {
      showDialog(
        context: _context,
        builder: (context) => DiscardChangesDialog(color: tribeColor),
      );
    } else {
      _navigationService.back();
    }
  }

  void onSecretPress() {
    if (firstToggle) {
      _firstToggle = false;

      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(Constants.dialogCornerRadius),
            ),
          ),
          title: Text(
            'Secret Tribe',
            style: TextStyle(
              fontFamily: 'TribesRounded',
              fontWeight: Constants.defaultDialogTitleFontWeight,
              fontSize: Constants.defaultDialogTitleFontSize,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Abort',
                style: TextStyle(
                  color: tribeColor,
                  fontFamily: 'TribesRounded',
                ),
              ),
              onPressed: _navigationService.back,
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: tribeColor,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _isSecret = !isSecret;
                notifyListeners();
                _navigationService.back();
              },
            ),
          ],
          content: Container(
            child: RichText(
              text: const TextSpan(
                text: 'This will make your Tribe',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'TribesRounded',
                ),
                children: const <TextSpan>[
                  TextSpan(
                    text: ' secret ',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'TribesRounded',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: 'and can only be found by typing in the',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'TribesRounded'),
                  ),
                  TextSpan(
                    text: ' exact ',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'TribesRounded',
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Tribe name.',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'TribesRounded'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      _isSecret = !isSecret;
    }
    notifyListeners();
  }

  void onColorPick() {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(Constants.dialogCornerRadius),
          ),
        ),
        title: Text(
          'Pick a Tribe color',
          style: TextStyle(
            fontFamily: 'TribesRounded',
            fontWeight: Constants.defaultDialogTitleFontWeight,
            fontSize: Constants.defaultDialogTitleFontSize,
          ),
        ),
        content: SingleChildScrollView(
          child: BlockPicker(
            availableColors: Constants.defaultTribeColors,
            pickerColor: tribeColor,
            onColorChanged: _changeColor,
          ),
        ),
      ),
    );
  }

  Future onCreateTribe() async {
    if (_formKey.currentState.validate()) {
      setBusy(true);
      try {
        DatabaseService().createNewTribe(
          currentUserId,
          name,
          desc,
          tribeColor != null
              ? tribeColor.value.toRadixString(16)
              : Constants.primaryColor.value.toRadixString(16),
          null,
          isSecret,
        );
        _navigationService.back();
      } catch (e) {
        print(e.toString());
        _error = 'Unable to create new Tribe';
        notifyListeners();
        setBusy(false);
      }
    }
  }

  Future<bool> onWillPop() {
    FocusScope.of(_context).requestFocus(FocusNode());
    _navigationService.back();
    return Future.value(true);
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
