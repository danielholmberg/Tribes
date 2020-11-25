import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/core/chat/chat_room_view.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_page_transition.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

// ToDo - Change to Stateless widget and move all state and business-logic to related [viewName]_view_model.dart file.

class NewChatView extends StatefulWidget {
  final String currentUserID;
  NewChatView({@required this.currentUserID});

  @override
  _NewChatViewState createState() => _NewChatViewState();
}

class _NewChatViewState extends State<NewChatView> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MyUser> _friendsList = [];
  List<MyUser> _searchResult = [];
  bool loading = false;
  String error = '';
  TextEditingController controller = new TextEditingController();
  Future friendsFuture;

  final EdgeInsets gridPadding = const EdgeInsets.fromLTRB(12.0, 82.0, 12.0, 12.0);

  @override
  void initState() {
    friendsFuture = DatabaseService().friendsList(widget.currentUserID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    _onSearchTextChanged(String text) async {
      _searchResult.clear();
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      _friendsList.forEach((friend) {
        if (friend.name.toLowerCase().contains(text.toLowerCase()) || 
        friend.username.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add(friend);
        }
      });

      setState(() {});
    }
    
    _friendTile(MyUser friend) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        leading: UserAvatar(
          currentUserID: widget.currentUserID, 
          user: friend, 
          radius: 20, 
          withName: true,
          withUsername: true,
          cornerRadius: 0.0,
          color: themeData.primaryColor,
          textColor: themeData.primaryColor,
          textPadding: const EdgeInsets.only(left: 8.0),
        ),
        trailing: FloatingActionButton(
          heroTag: 'newChatButton-${friend.id}',
          elevation: 4.0,
          mini: true,
          child: CustomAwesomeIcon(
            icon: FontAwesomeIcons.pen,
            size: Constants.smallIconSize,
          ),
          backgroundColor: themeData.primaryColor,
          onPressed: () async {
           String roomID = await DatabaseService().createNewPrivateChatRoom(widget.currentUserID, friend.id);

            Navigator.push(context, 
              CustomPageTransition(
                type: CustomPageTransitionType.chatRoom, 
                duration: Constants.pageTransition600, 
                child: ChatRoomView(roomID: roomID, members: [widget.currentUserID, friend.id], reply: true),
              )
            );
          }
        ),
      );
    }
    
    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeData.primaryColor,
      body: SafeArea(
        child: Container(
          color: themeData.backgroundColor,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: FutureBuilder<List<MyUser>>(
                  future: friendsFuture,
                  builder: (context, snapshot) {

                    if(snapshot.hasData) {
                      _friendsList = snapshot.data;

                      return Container(
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(), 
                          child: _searchResult.length != 0 || controller.text.isNotEmpty
                          ? ListView.builder(
                            padding: gridPadding,
                            itemCount: _searchResult.length,
                            itemBuilder: (context, i) {
                              return _friendTile(_searchResult[i]); 
                            }
                          )
                          : ListView.builder(
                            padding: gridPadding,
                            itemCount: _friendsList.length,
                            itemBuilder: (context, i) {
                              return _friendTile(_friendsList[i]);
                            },
                          ),
                        ),
                      );
                    } else if(snapshot.hasError){
                      print('Error retrieving friends: ${snapshot.error.toString()}');
                      return Center(child: Text('Unable to retrieve friends'));
                    } else {
                      return Center(child: Loading());
                    }
                  }
                )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.all(12.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ]
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Leading Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft,
                              color: themeData.primaryColor
                            ), 
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Icon(FontAwesomeIcons.search, color: Colors.black54, size: Constants.smallIconSize),
                        ],
                      ),

                      SizedBox(width: Constants.largePadding),

                      // Center Widget
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Find your friend', 
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontFamily: 'TribesRounded',
                              fontSize: 16,
                              color: Colors.black54.withOpacity(0.3),
                            ),
                          ),
                          onChanged: _onSearchTextChanged,
                        )
                      ),

                      // Trailing Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.solidTimesCircle,
                              color: controller.text.isEmpty ? Colors.grey : themeData.primaryColor,
                            ), 
                            onPressed: () {
                              controller.clear();
                              _onSearchTextChanged('');
                            },
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}