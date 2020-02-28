import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/NotificationData.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/Chats.dart';
import 'package:tribes/screens/home/tabs/profile/Profile.dart';
import 'package:tribes/screens/home/tabs/tribes/Tribes.dart';
import 'package:tribes/screens/home/tabs/map/MyMap.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomBottomNavBar.dart';
import 'package:tribes/shared/widgets/CustomNavBarItem.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';

  final int tabIndex; // Used for Tab specific Routing purposes
  Home({this.tabIndex});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  int _currentIndex = 0;
  final List<Widget> _tabList = [Tribes(), MyMap(), Chats(), Profile()];
  TabController _tabController;
  StreamSubscription iosSubscription;

  void _setUpFCM() {
    if (Platform.isIOS) {
      iosSubscription = DatabaseService().fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        DatabaseService().saveFCMToken();
      });

      DatabaseService().fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      DatabaseService().saveFCMToken();
    }

    DatabaseService().fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        var messageData = message['data'];
        
        // Do nothing as of now. TODO: Show a badge in BottomNavBar on Chat-tab, indicating a new chat message.
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        var messageData = message['data'];

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
        print("onResume: $message");
        var messageData = message['data'];

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

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _tabController = TabController(length: _tabList.length, vsync: this);
    if(widget.tabIndex != null) {
      _currentIndex = widget.tabIndex;
      _tabController.animateTo(widget.tabIndex);
    }

    _setUpFCM();

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    _tabController.dispose();
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  void _onTabTap(int currentIndex) {
    print('$currentIndex');
    _tabController.animateTo(currentIndex);
    setState(() {
      _currentIndex = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return StreamProvider<UserData>.value(
      value: DatabaseService().currentUser(user.uid),
      child: Scaffold(
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(), // Disable horizontal swipe
          controller: _tabController,
          children: _tabList,
        ),
        extendBody: true, // In order to show screen behind navigation bar
        bottomNavigationBar: Container(
          child: CustomBottomNavBar(
            currentIndex: _currentIndex,
            backgroundColor: DynamicTheme.of(context).data.primaryColor,
            selectedItemColor: DynamicTheme.of(context).data.primaryColor,
            iconSize: 20.0,
            fontSize: 12.0,
            items: [
              CustomNavBarItem(icon: FontAwesomeIcons.campground, title: 'Tribes'),
              CustomNavBarItem(icon: FontAwesomeIcons.mapMarkedAlt, title: 'Map'),
              CustomNavBarItem(icon: FontAwesomeIcons.solidComments, title: 'Chat'),
              CustomNavBarItem(icon: FontAwesomeIcons.solidUser, title: 'Profile'),
            ],
            onTap: (index) {
              _onTabTap(index);
              return index;
            },
          ),
        ),
      ),
    );
  }
}
