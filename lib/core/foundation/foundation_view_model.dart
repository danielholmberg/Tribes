import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/core/chat/chat_view.dart';
import 'package:tribes/core/home/home_view.dart';
import 'package:tribes/core/map/map_view.dart';
import 'package:tribes/core/profile/profile_view.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';

class FoundationViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final List<Widget> _tabList = [
    HomeView(),
    MapView(),
    ChatView(),
    ProfileView()
  ];
  TabController _tabController;
  StreamSubscription _iosSubscription;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _currentIndex = 0;
  String _username = '';
  String _name = '';
  bool _usernameAlreadyInUse = false;

  GlobalKey<FormState> get formKey => _formKey;
  MyUser get currentUser => _databaseService.currentUserData;
  String get username => currentUser.username;
  String get name =>
      currentUser != null ? currentUser.name.split(' ')[0] : _name;
  TabController get tabController => _tabController;
  List<Widget> get tabList => _tabList;
  int get currentTabIndex => _currentIndex;
  bool get usernameAlreadyInUse => _usernameAlreadyInUse;
  bool get currentUserHasUsername => currentUser.hasUsername;

  List<TextInputFormatter> get inputFormatters =>
      [new FilteringTextInputFormatter.deny(new RegExp('[\\ ]'))];

  Future initState({@required TickerProvider vsync}) async {
    _tabController = TabController(length: _tabList.length, vsync: vsync);
    _tabController.animateTo(0);
    setCurrentTab(0);

    await _initFCM();
  }

  Future _initFCM() async {
    if (Platform.isIOS) {
      // _iosSubscription = _databaseService.fcm.onIosSettingsRegistered((data) {
      //   _databaseService.saveFCMToken();
      // });

      NotificationSettings settings = await _databaseService.fcm.requestPermission();
      print('iOS FCM permission status: ${settings.authorizationStatus}');
    } else {
      _databaseService.saveFCMToken();
    }

    // Called when an incoming FCM payload is received whilst the Flutter instance is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: ${message.toString()}');
        var messageData = message.data;
        var routeName = messageData['routeName'];
        var tab = messageData['tab'];
        var senderID = messageData['senderID'];

        if (routeName == '/home/chats') {
          /* locator<NavigationService>().navigateTo(ChatView.routeName, arguments: NotificationData(
            routeName: routeName,
            tab: tab,
            senderID: senderID,
          )); */
        }
    });

    // Called when a user presses a notification displayed via FCM.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp: ${message.toString()}');
        var messageData = message.data;
        var routeName = messageData['routeName'];
        var tab = messageData['tab'];
        var senderID = messageData['senderID'];

        if (routeName == '/home/chats') {
          /* locator<NavigationService>().navigateTo(ChatView.routeName, arguments: NotificationData(
            routeName: routeName,
            tab: tab,
            senderID: senderID,
          )); */
        }
    });

    // Sets a background message handler to trigger when the app is in the background or terminated.
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      print('onBackgroundMessage. ${message.toString()}');
      return;
    });

    print('FCM configured!');
  }

  void back() {
    _navigationService.back();
  }

  String usernameValidator(String value) {
    return value.toString().trim().isEmpty
        ? 'Oops, you need to enter a username'
        : null;
  }

  void onUsernameChanged(String value) {
    _username = value;
    notifyListeners();
  }

  Future onUsernameSubmitted(String value) async {
    if (_formKey.currentState.validate()) {
      _usernameAlreadyInUse = await _databaseService.updateUsername(
        _username,
      );
      notifyListeners();
    }
  }

  void setCurrentTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  int onTabTap(int index) {
    _tabController.animateTo(index);
    setCurrentTab(index);
    return index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_iosSubscription != null) _iosSubscription.cancel();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
