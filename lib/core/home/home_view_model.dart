import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class HomeViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final PageController _tribeItemController = new PageController(
    viewportFraction: 0.8,
  );

  int _currentPageIndex =
      0; // Keep track of current page to avoid unnecessary renders

  Stream<List<Tribe>> get joinedTribes => _databaseService.joinedTribes;

  MyUser get currentUser => _databaseService.currentUserData;
  int get currentPageIndex => _currentPageIndex;
  PageController get tribeItemController => _tribeItemController;

  void initState() {
    _tribeItemController.addListener(() {
      int next = _tribeItemController.page.round();

      if (_currentPageIndex != next) {
        setCurrentPage(next);
      }
    });
  }

  void setCurrentPage(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  void showNewTribePage() {
    _navigationService.navigateTo(MyRouter.newTribeRoute);
  }

  void showJoinTribePage() {
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  void showTribeRoom(String tribeId) {
    _navigationService.navigateTo(
      MyRouter.tribeRoomRoute,
      arguments: tribeId,
    );
  }

  @override
  void dispose() {
    _tribeItemController.dispose();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
