import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/widgets/CategorySelector.dart';
import 'package:tribes/screens/home/tabs/chats/widgets/FavoriteContacts.dart';
import 'package:tribes/screens/home/tabs/chats/widgets/RecentMessages.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Chats()...');
    print('Current user ${currentUser.toString()}');

    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      appBar: AppBar(
        backgroundColor: DynamicTheme.of(context).data.primaryColor,
        elevation: 0.0,
        title: Text(
          'Chats', 
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {print('Clicked on More button');},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          CategorySelector(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DynamicTheme.of(context).data.accentColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ]
              ),
              child: Column(
                children: <Widget>[
                  FavoriteContacts(),
                  RecentMessages(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
