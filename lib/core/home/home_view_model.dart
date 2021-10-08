import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/test_keys.dart';
class HomeViewModel extends StreamViewModel<List<Tribe>> {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  String _PreferredGridLayoutKey = "PreferredGridLayoutKey";

  SharedPreferences _prefs;
  List<Tribe> _tribeList;
  List<String> _tribeListOrder;
  bool _gridHasMultipleColumns = false;
  int _currentDragTargetIndex;

  bool hasUpdatedTribeItemSize = false;
  double tribeItemWidth;
  double tribeItemHeight;

  String get appTitle => Constants.appTitle;
  ValueKey get appTitleKey => ValueKey(TestKeys.homeAppTitle);
  bool get gridHasMultipleColumns => _gridHasMultipleColumns;
  int get currentDragTargetIndex => _currentDragTargetIndex;

  List<Tribe> get joinedTribes => _tribeList;
  MyUser get currentUser => _databaseService.currentUserData;

  void initState() async {
    _prefs = await SharedPreferences.getInstance();
    _tribeList = List.empty(growable: true);
    _tribeListOrder = _prefs.getStringList(currentUser.id) ?? List.empty(growable: true);;
    _gridHasMultipleColumns = _prefs.getInt(_PreferredGridLayoutKey) == 2;
    print('INIT tribeList: $_tribeListOrder');
  }

  void showNewTribePage() {
    _navigationService.navigateTo(MyRouter.newTribeRoute);
  }

  void showJoinTribePage() {
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  void showTribeRoom(Tribe tribe) {
    _navigationService.navigateTo(
      MyRouter.tribeRoomRoute,
      arguments: TribeRoomArguments(
        tribeId: tribe.id,
        tribeColor: tribe.color,
      ),
    );
  }

  saveTribeListOrder(List<Tribe> tribes) async {
    List<String> newTribeListOrder = [];
    tribes.forEach((tribe) {
      newTribeListOrder.add(tribe.id);
    });
    await _prefs.setStringList(currentUser.id, newTribeListOrder);
    _tribeListOrder = newTribeListOrder;
    print('new tribeListOrder: $newTribeListOrder');
  }

  Future<void> toggleGridLayout() async {
    hasUpdatedTribeItemSize = false;
    _gridHasMultipleColumns = !_gridHasMultipleColumns;
    await savePreferredGridLayout();
    notifyListeners();
  }

  Future<void> savePreferredGridLayout() async {
    await _prefs.setInt(_PreferredGridLayoutKey, _gridHasMultipleColumns ? 2 : 1);
    print('Saved preferred Grid layout: ${gridHasMultipleColumns ? 'MULTIPLE': 'SINGLE'}');
  }

  void setCurrentDragTargetIndex(int newIndex) {
    _currentDragTargetIndex = newIndex;
    notifyListeners();
  }

  @override
  void onData(List<Tribe> data) {
    super.onData(data);

    print('onData: $data');
    print('_tribeListOrder: $_tribeListOrder');

    if (data == null) {
      _tribeList = List.empty(growable: true);
      return;
    };

    List<Tribe> newTribeList = List.empty(growable: true);
    print('newTribeList: $newTribeList');
    newTribeList.length = data.length > _tribeListOrder.length ? data.length : _tribeListOrder.length;

    data.forEach((tribe) {
      if (tribe == null) return;

      if (_tribeListOrder.contains(tribe.id)) {
        int index = _tribeListOrder.indexOf(tribe.id);
        if (newTribeList.isEmpty) {
          newTribeList.add(tribe);
        } else {
          newTribeList.insert(index, tribe);
        }
      } else {
        newTribeList.add(tribe);
      }
    });

    newTribeList.removeWhere((tribe) => tribe == null);
    _tribeList = newTribeList;

    List<String> _incomingTribeListOrder = _tribeList.map((tribe) => tribe.id).toList();
    if (!_incomingTribeListOrder.every((tribeId) => _tribeListOrder.contains(tribeId))) {
      saveTribeListOrder(_tribeList);
    }

  }

  @override
  Stream<List<Tribe>> get stream => _databaseService.joinedTribes;
}
