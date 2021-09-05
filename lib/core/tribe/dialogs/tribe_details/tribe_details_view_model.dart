import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeDetailsViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  List<MyUser> _membersList = [];
  List<MyUser> _searchResult = [];

  TextEditingController controller = new TextEditingController();
  Future _membersFuture;

  Tribe _currentTribe;

  List<MyUser> get membersList => _membersList;
  List<MyUser> get searchList => _searchResult;

  int get searchResultCount => _searchResult.length;
  int get membersCount => _membersList.length;

  MyUser get currentUser => _databaseService.currentUserData;
  bool get isFounder =>
      _currentTribe != null ? currentUser.id == _currentTribe.founder : false;

  Future get membersFuture => _membersFuture;

  Tribe get currentTribe => _currentTribe;
  Color get currentTribeColor => _currentTribe.color ?? Constants.primaryColor;

  Stream<MyUser> get tribeFounderStream =>
      _databaseService.userData(_currentTribe.founder);

  void initState({@required Tribe tribe}) {
    _currentTribe = tribe;
    _membersFuture = _databaseService.tribeMembersList(tribe.members);
  }

  void onSaveUpdatedTribe(Tribe newTribe) {
    _currentTribe = newTribe;
    notifyListeners();
  }

  void setMembersList(List<MyUser> membersList) {
    _membersList = membersList;
  }

  MyUser getUserFromSearch(int index) {
    return _searchResult[index];
  }

  MyUser getUserFromMembers(int index) {
    return _membersList[index];
  }

  Future onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    _membersList.forEach((friend) {
      if (friend.name.toLowerCase().contains(text.toLowerCase()) ||
          friend.username.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(friend);
      }
    });

    notifyListeners();
  }

  void onSearchTextClearPress() {
    controller.clear();
    onSearchTextChanged('');
  }

  Future<void> onLeaveTribe() async {
    try {
      await _databaseService.leaveTribe(currentTribe.id);
      _navigationService.popUntil((route) => route.isFirst);
    } catch(error) {
      await _dialogService.showDialog(
        title: 'Failed to leave Tribe!',
        description: 'An error occurred trying to leave this Tribe, please try again later.',
      );
    }
  }

  Future<void> onDeleteTribe() async {
    try {
      await _databaseService.deleteTribe(currentTribe.id);
      _navigationService.popUntil((route) => route.isFirst);
    } catch(error) {
      await _dialogService.showDialog(
        title: 'Failed to delete Tribe!',
        description: 'An error occurred trying to delete this Tribe, please try again later.',
      );
      _navigationService.back();
    }
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
