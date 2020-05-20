import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/NotificationData.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/chats/screens/NewChat.dart';
import 'package:tribes/screens/base/chats/widgets/PrivateMessages.dart';
import 'package:tribes/screens/base/chats/widgets/TribeMessages.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomPageTransition.dart';

class Chats extends StatefulWidget {
  static const routeName = '/home/chats';

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> with AutomaticKeepAliveClientMixin {

  int _currentTab = 0;
  final List<String> tabs = ['Private', 'Tribes'];
  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Chats()...');

    final NotificationData notificationData = firstBuild ? ModalRoute.of(context).settings.arguments : null;
    if(firstBuild) firstBuild = false;

    if(notificationData != null) {
      switch (notificationData.tab) {
        case 'Private':
          _currentTab = 0;
          break;
        case 'Tribes':
          _currentTab = 1;
          break;
        default:
          _currentTab = _currentTab;
      }
    }

    _categorySelector() {
      return Container(
        height: 60.0,
        color: DynamicTheme.of(context).data.primaryColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Center(
              child: GestureDetector(
                onTap: () => setState(() => _currentTab = index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: index == _currentTab ? Colors.white : Colors.white60,
                      fontFamily: 'TribesRounded',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    _buildAppBar() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.search),
              iconSize: Constants.defaultIconSize,
              color: Colors.white,
              onPressed: () => Fluttertoast.showToast(
                msg: 'Coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              ),
            ),
            _categorySelector(),
            IconButton(
              icon: Icon(FontAwesomeIcons.commentMedical),
              iconSize: Constants.defaultIconSize,
              color: Colors.white,
              onPressed: () => Navigator.push(context, 
                CustomPageTransition(
                  type: CustomPageTransitionType.newMessage, 
                  duration: Constants.pageTransition600, 
                  child: StreamProvider<UserData>.value(
                    value: DatabaseService().currentUser(currentUser.uid), 
                    child: NewChat(currentUserID: currentUser.uid),
                  ),
                )
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          body: Column(
            children: <Widget>[
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: DynamicTheme.of(context).data.backgroundColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ]
                  ),
                  child: _currentTab == 0 ? PrivateMessages() : TribeMessages(), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
