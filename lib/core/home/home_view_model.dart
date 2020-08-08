import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/join_tribe_view.dart';
import 'package:tribes/core/tribe/new_tribe_view.dart';
import 'package:tribes/core/tribe/tribe_room_view.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/services/firebase_auth_service.dart';
import 'package:tribes/shared/widgets/custom_page_transition.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class HomeViewModel extends StreamViewModel<List<Tribe>> {
  final BuildContext context;
  HomeViewModel({this.context});

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  // -------------- Services [END] --------------- //
  
  // -------------- Models [START] --------------- //
  final PageController _tribeItemController = PageController(
    viewportFraction: 0.8,
  );
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  int _currentPageIndex = 0; // Keep track of current page to avoid unnecessary renders
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  void setCurrentPage(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  UserData get currentUser => _databaseService.currentUserData;
  List<Tribe> get joinedTribes => data;
  int get currentPage => _currentPageIndex;
  PageController get tribeItemController => _tribeItemController;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  void showNewTribePage() {
    Navigator.push(context, CustomPageTransition(
      type: CustomPageTransitionType.newTribe,
      child: NewTribeView(),
    ));
  }

  void showJoinTribePage() {
    Navigator.push(context, CustomPageTransition(
      type: CustomPageTransitionType.joinTribe,
      child: JoinTribeView(),
    ));
  }
  // -------------- Logic [END] --------------- //

  @override
  void initialise() {
    _tribeItemController.addListener(() {
      int next = _tribeItemController.page.round();

      if (_currentPageIndex != next) {
        setCurrentPage(next);
      }
    });
    super.initialise();
  }

  void showTribeRoom() {
    Navigator.push(context, CustomPageTransition(
      type: CustomPageTransitionType.tribeRoom,
      child: TribeRoomView(tribeID: joinedTribes[_currentPageIndex].id),
    ));
  }

  @override
  void dispose() {
    _tribeItemController.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Stream<List<Tribe>> get stream => _databaseService.joinedTribes(_databaseService.currentUserData.id);

}