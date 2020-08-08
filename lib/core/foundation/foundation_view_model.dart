import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/chat_view.dart';
import 'package:tribes/core/home/home_view.dart';
import 'package:tribes/core/map/map_view.dart';
import 'package:tribes/core/profile/profile_view.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/services/firebase_auth_service.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class FoundationViewModel extends StreamViewModel<UserData> {

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  // -------------- Services [END] --------------- //

  // -------------- Models [START] --------------- //
  final List<Widget> _tabList = [HomeView(), MapView(), ChatView(), ProfileView()];
  TabController _tabController;
  StreamSubscription iosSubscription;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  int _currentIndex = 0;
  String _username = '';
  String _name = '';
  bool _showUnavailableUsernameDialog = false;
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  void setCurrentTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }
  void setUsername(String username) => _username = username;
  void toggleUnavailableUsernameDialog() {
    _showUnavailableUsernameDialog = !_showUnavailableUsernameDialog;
    notifyListeners();
  }
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  GlobalKey<FormState> get formKey => _formKey;
  UserData get currentUser => data;
  String get username => currentUser.username;
  String get name => currentUser != null ? currentUser.name.split(' ')[0] : _name;
  TabController get tabController => _tabController;
  List<Widget> get tabList => _tabList;
  int get currentTabIndex => _currentIndex;
  bool get showUnavailableUsernameDialog => _showUnavailableUsernameDialog;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //

  void onUsernameSubmitted() async {
    if(_formKey.currentState.validate()) {
      bool available = await _databaseService.updateUsername(
        currentUser.id,
        _username,
      );

      toggleUnavailableUsernameDialog();
    }
  }

  void initFCM() {
    if (Platform.isIOS) {
      iosSubscription = _databaseService.fcm.onIosSettingsRegistered.listen((data) {
        _databaseService.saveFCMToken();
      });

      _databaseService.fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _databaseService.saveFCMToken();
    }

    _databaseService.fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        // var messageData = message['data'];
        
        // Do nothing as of now. TODO: Show a badge in BottomNavBar on Chat-tab, indicating a new chat message.
      },
      onLaunch: (Map<String, dynamic> message) async {
        // var messageData = message['data'];

        // TODO: Fix bug when navigating to route.
        /* Navigator.of(context).pushNamed(
          messageData['routeName'], 
          arguments: NotificationData(
            routeName: messageData['routeName'],
            tab: messageData['tab'],
            senderID: messageData['senderID'],
          ),
        ); */
      },
      onResume: (Map<String, dynamic> message) async {
        // var messageData = message['data'];

        // TODO: Fix bug when navigating to route.
        /* Navigator.of(context).pushNamed(
          messageData['routeName'], 
          arguments: NotificationData(
            routeName: messageData['routeName'],
            tab: messageData['tab'],
            senderID: messageData['senderID'],
          ),
        ); */
      },
    );

    print('FCM configured!');
  }

  int onTabTap(int index) {
    _tabController.animateTo(index);
    setCurrentTab(index);
    return index;
  }
  // -------------- Logic [END] --------------- //

  void initState(TickerProvider vsync, int index) {
    //_authService.signOut();

    _tabController = TabController(length: _tabList.length, vsync: vsync);
    if(index != null) {
      _tabController.animateTo(index);
      setCurrentTab(index);
    }

    // StatusBar Color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent
    ));

    initFCM();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Stream<UserData> get stream => _databaseService.currentUserDataStream(firebaseUserID: _authService.currentFirebaseUser.id);
}