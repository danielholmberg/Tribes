import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/notification_data_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/extensions.dart';

class ChatViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final List<String> _tabs = [
    Constants.privateChatTabTitle,
    Constants.tribesChatTabTitle
  ];

  NotificationData _notificationData;

  int _currentTabIndex = 0;

  MyUser get currentUser => _databaseService.currentUserData;
  int get currentTabIndex => _currentTabIndex;

  List<String> get tabs => _tabs;
  int get tabsCount => _tabs.length;

  Widget get currentTabAppBarLeftButton {
    switch (currentTabIndex) {
      case 0:
      case 1:
      default:
        return IconButton(
          icon: Icon(FontAwesomeIcons.ban),
          iconSize: Constants.defaultIconSize,
          color: Colors.white.withOpacity(0.2),
          onPressed: onStartNewChat,
        ).hideButFillSpace();
    }
  }

  Widget get currentTabAppBarRightButton {
    switch (currentTabIndex) {
      case 0:
        return IconButton(
          icon: Icon(FontAwesomeIcons.commentMedical),
          iconSize: Constants.defaultIconSize,
          color: Colors.white,
          onPressed: onStartNewChat,
        );
      case 1:
        return IconButton(
          icon: Icon(FontAwesomeIcons.search),
          iconSize: Constants.defaultIconSize,
          color: Colors.white,
          onPressed: showJoinTribePage,
        );
      default:
        return IconButton(
          icon: Icon(FontAwesomeIcons.ban),
          iconSize: Constants.defaultIconSize,
          color: Colors.white.withOpacity(0.2),
          onPressed: onStartNewChat,
        ).hideButFillSpace();
    }
  }

  void initState({@required BuildContext context}) {
    _notificationData = ModalRoute.of(context).settings.arguments;

    if (_notificationData != null) {
      switch (_notificationData.tab) {
        case Constants.privateChatTabTitle:
          setCurrentTab(0);
          break;
        case Constants.tribesChatTabTitle:
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

  void showJoinTribePage() {
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  void onStartNewChat() {
    _navigationService.navigateTo(MyRouter.newChatRoute);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
