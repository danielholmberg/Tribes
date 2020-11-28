import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/notification_data_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class ChatViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final List<String> _tabs = ['Private', 'Tribes'];

  NotificationData _notificationData;

  int _currentTabIndex = 0;

  MyUser get currentUser => _databaseService.currentUserData;
  int get currentTabIndex => _currentTabIndex;

  List<String> get tabs => _tabs;
  int get tabsCount => _tabs.length;

  void initState({@required BuildContext context}) {
    _notificationData = ModalRoute.of(context).settings.arguments;

    if (_notificationData != null) {
      switch (_notificationData.tab) {
        case 'Private':
          setCurrentTab(0);
          break;
        case 'Tribes':
          setCurrentTab(1);
          break;
        default:
          setCurrentTab(_currentTabIndex);
      }
    }
  }

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  String getTab(int index) {
    return _tabs[index];
  }

  void onStartNewChat() {
    _navigationService.navigateTo(MyRouter.newChatRoute);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
