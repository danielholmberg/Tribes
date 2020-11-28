import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PasswordViewModel extends ReactiveViewModel {
  final Tribe activeTribe;
  final Function showJoinedSnackbar;
  PasswordViewModel({
    @required this.activeTribe,
    @required this.showJoinedSnackbar,
  });

  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final FocusNode _nodeOne = new FocusNode();
  final FocusNode _nodeTwo = new FocusNode();
  final FocusNode _nodeThree = new FocusNode();
  final FocusNode _nodeFour = new FocusNode();
  final FocusNode _nodeFive = new FocusNode();
  final FocusNode _nodeSix = new FocusNode();

  BuildContext _context;

  String _one = '', _two = '', _three = '', _four = '', _five = '', _six = '';
  String _error = '';

  Color get activeTribeColor => activeTribe.color ?? Constants.primaryColor;

  GlobalKey<FormState> get passwordFormKey => _passwordFormKey;
  List<TextInputFormatter> get inputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ];

  FocusNode get nodeOne => _nodeOne;
  FocusNode get nodeTwo => _nodeTwo;
  FocusNode get nodeThree => _nodeThree;
  FocusNode get nodeFour => _nodeFour;
  FocusNode get nodeFive => _nodeFive;
  FocusNode get nodeSix => _nodeSix;

  String get one => _one;
  String get two => _two;
  String get three => _three;
  String get four => _four;
  String get five => _five;
  String get six => _six;

  String get currentError => _error;

  void initState(BuildContext context) {
    _context = context;
  }

  void _onCorrectPassword() {
    setBusy(true);

    _databaseService.addUserToTribe(activeTribe.id);
    showJoinedSnackbar(activeTribe);

    setBusy(false);
    _navigationService.back();
  }

  void onFirstDigitChanged(String value) {
    if (activeTribe.password == '$value$_two$_three$_four$_five$_six') {
      _onCorrectPassword();
    } else {
      _one = value;
      _error = '';
      notifyListeners();
      FocusScope.of(_context).requestFocus(value.isEmpty ? _nodeOne : _nodeTwo);
    }
  }

  void onSecondDigitChanged(String value) {
    if (activeTribe.password == '$_one$value$_three$_four$_five$_six') {
      _onCorrectPassword();
    } else {
      _two = value;
      _error = '';
      notifyListeners();
      FocusScope.of(_context)
          .requestFocus(value.isEmpty ? _nodeOne : _nodeThree);
    }
  }

  void onThirdDigitChanged(String value) {
    if (activeTribe.password == '$_one$_two$value$_four$_five$_six') {
      _onCorrectPassword();
    } else {
      _three = value;
      _error = '';
      notifyListeners();
      FocusScope.of(_context)
          .requestFocus(value.isEmpty ? _nodeTwo : _nodeFour);
    }
  }

  void onFourthDigitChanged(String value) {
    if (activeTribe.password == '$_one$_two$_three$value$_five$_six') {
      _onCorrectPassword();
    } else {
      _four = value;
      _error = '';
      notifyListeners();
      FocusScope.of(_context)
          .requestFocus(value.isEmpty ? _nodeThree : _nodeFive);
    }
  }

  void onFifthDigitChanged(String value) {
    if (activeTribe.password == '$_one$_two$_three$_four$value$_six') {
      _onCorrectPassword();
    } else {
      _five = value;
      _error = '';
      notifyListeners();
      FocusScope.of(_context)
          .requestFocus(value.isEmpty ? _nodeFour : _nodeSix);
    }
  }

  void onSixthDigitChanged(String value) {
    if (activeTribe.password == '$_one$_two$_three$_four$_five$value') {
      _onCorrectPassword();
    } else {
      _six = value;
      _error = '';
      notifyListeners();
      FocusScope.of(_context)
          .requestFocus(value.isEmpty ? _nodeFive : _nodeSix);
    }
  }

  void onFirstDigitSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_nodeTwo);
  }

  void onSecondDigitSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_nodeThree);
  }

  void onThirdDigitSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_nodeFour);
  }

  void onFourthDigitSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_nodeFive);
  }

  void onFifthDigitSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_nodeSix);
  }

  void onSixthDigitSubmitted(String value) {
    if (activeTribe.password == '$one$two$three$four$five$value') {
      _onCorrectPassword();
    } else {
      _error = 'Wrong passord';
    }
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
