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
import 'package:tribes/screens/auth/auth.dart';
import 'package:tribes/screens/base/chats/Chats.dart';
import 'package:tribes/screens/base/profile/Profile.dart';
import 'package:tribes/screens/base/tribes/Tribes.dart';
import 'package:tribes/screens/base/map/MyMap.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomBottomNavBar.dart';
import 'package:tribes/shared/widgets/CustomNavBarItem.dart';
import 'package:tribes/shared/widgets/CustomRaisedButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class Base extends StatefulWidget {
  static const routeName = '/home';

  final int tabIndex; // Used for Tab specific Routing purposes
  Base({this.tabIndex});

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> with SingleTickerProviderStateMixin{

  int _currentIndex = 0;
  final List<Widget> _tabList = [Tribes(), MyMap(), Chats(), Profile()];
  TabController _tabController;
  StreamSubscription iosSubscription;

  String username = '';

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
    _tabController = TabController(length: _tabList.length, vsync: this);
    if(widget.tabIndex != null) {
      _currentIndex = widget.tabIndex;
      _tabController.animateTo(widget.tabIndex);
    }

    // StatusBar Color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent
    ));

    _setUpFCM();

    super.initState();
  }

  @override
  void dispose() {
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

    _showUnavailableUsernameDialog() {
      showDialog(
        context: context,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
          title: Text('Username already in use',
            style: TextStyle(
              fontFamily: 'TribesRounded',
              fontWeight: Constants.defaultDialogTitleFontWeight,
              fontSize: Constants.defaultDialogTitleFontSize,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK', 
                style: TextStyle(
                  color: DynamicTheme.of(context).data.primaryColor,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: RichText(
                  maxLines: null,
                  softWrap: true,
                  text: TextSpan(
                    text: 'The username ',
                    style: DynamicTheme.of(context).data.textTheme.body1,
                    children: <TextSpan>[
                      TextSpan(
                        text: username,
                        style: DynamicTheme.of(context).data.textTheme.body1.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' is already in use by a fellow Tribe explorer, please try another one.',
                        style: DynamicTheme.of(context).data.textTheme.body1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }

    _buildIntro(UserData currentUser) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: DynamicTheme.of(context).data.primaryColor,
        body: Center(
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView(
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome ${currentUser.name.split(' ')[0]}!', 
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    style: DynamicTheme.of(context).data.textTheme.title.copyWith(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RichText(
                    maxLines: null,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Before you can begin to ',
                      style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'explore',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'share',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' your thoughts and dreams with your ',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Tribes',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' we first need you to enter your very own ',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Username',
                          style: DynamicTheme.of(context).data.textTheme.body1.copyWith(color: Colors.white, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                  cursorRadius: Radius.circular(1000),
                  maxLength: Constants.profileUsernameMaxLength,
                  decoration: Decorations.registerInput.copyWith(
                    hintText: 'Username', 
                    prefixIcon: Icon(FontAwesomeIcons.userSecret, color: Constants.primaryColor)
                  ),
                  inputFormatters: [
                    new BlacklistingTextInputFormatter(new RegExp('[\\ ]')),
                  ],
                  onChanged: (val) => setState(() => username = val),
                  onFieldSubmitted: (val) async {
                    bool available = await DatabaseService().updateUsername(
                      currentUser.uid,
                      username,
                    );

                    print('alreadyInUse: $available');

                    if(!available) {
                      _showUnavailableUsernameDialog();
                    }
                  }
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: CustomRaisedButton(
                      icon: CustomAwesomeIcon(
                        icon: FontAwesomeIcons.check, 
                        color: DynamicTheme.of(context).data.primaryColor,
                        size: 18,
                      ),
                      text: 'Submit',
                      inverse: true,
                      onPressed: () async {
                        bool available = await DatabaseService().updateUsername(
                          currentUser.uid,
                          username,
                        );

                        print('alreadyInUse: $available');

                        if(!available) {
                          _showUnavailableUsernameDialog();
                        }
                      }
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _buildBase() {
      return StreamProvider<UserData>.value(
        value: DatabaseService().currentUser(user.uid),
        child: Scaffold(
          resizeToAvoidBottomInset: false,  // Avoid resize due to eg. toggled keyboard
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
                CustomNavBarItem(icon: FontAwesomeIcons.home, title: 'Tribes'),
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

    return StreamBuilder<UserData>(
      stream: DatabaseService().currentUser(user.uid),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData currentUser = snapshot.data;
          return currentUser.username.isEmpty ? _buildIntro(currentUser) : _buildBase();
        } else if(snapshot.hasError) {
          print('Error retrieving Current user data: ${snapshot.error}');
          return Auth();
        } else {
          return Loading();
        }
      }
    );
  }
}
