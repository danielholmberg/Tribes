import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/notification_data_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class ChatViewModel extends BaseViewModel {
  final BuildContext context;
  ChatViewModel({this.context});

  // -------------- Services [START] --------------- //
  final DatabaseService _databaseService = locator<DatabaseService>();
  // -------------- Services [END] --------------- //
  
  // -------------- Models [START] --------------- //
  NotificationData notificationData; 
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  int _currentTab = 0;
  final List<String> tabs = ['Private', 'Tribes'];
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  void setCurrentTab(int index) {
    _currentTab = index;
    notifyListeners();
  }
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  UserData get currentUserData => _databaseService.currentUserData;
  int get currentTab => _currentTab;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  // -------------- Logic [END] --------------- //

  void initialise() {
    notificationData = ModalRoute.of(context).settings.arguments;

    switch (notificationData.tab) {
      case 'Private':
        setCurrentTab(0);
        break;
      case 'Tribes':
        setCurrentTab(1);
        break;
      default:
        setCurrentTab(_currentTab);
    }
  }

}