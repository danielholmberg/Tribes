import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/ChatRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class NewChat extends StatefulWidget {
  final String currentUserID;
  NewChat({this.currentUserID});

  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<UserData> _friendsList = [];
  List<UserData> _searchResult = [];
  bool loading = false;
  String error = '';
  TextEditingController controller = new TextEditingController();
  Future friendsFuture;

  @override
  void initState() {
    friendsFuture = DatabaseService().friendsList(widget.currentUserID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _friendTile(UserData friend) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        leading: userAvatar(friend, size: 20, withName: true),
        trailing: FloatingActionButton(
          heroTag: 'newChatButton-${friend.uid}',
          elevation: 4.0,
          mini: true,
          child: Icon(Icons.edit, color: Constants.buttonIconColor, size: 20),
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          onPressed: () async {
           String roomID = await DatabaseService().createNewChatRoom(widget.currentUserID, friend.uid);

            Navigator.push(context, 
              CustomPageTransition(
                type: CustomPageTransitionType.chatRoom, 
                duration: Constants.pageTransition600, 
                child: StreamProvider<UserData>.value(
                  value: DatabaseService().currentUser(widget.currentUserID), 
                  child: ChatRoom(roomID: roomID, members: [widget.currentUserID, friend.uid], reply: true),
                ),
              )
            );
          }
        ),
      );
    }
    
    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      backgroundColor: DynamicTheme.of(context).data.backgroundColor,
      body: SafeArea(
        child: Container(
          color: DynamicTheme.of(context).data.backgroundColor,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: FutureBuilder<List<UserData>>(
                  future: friendsFuture,
                  builder: (context, snapshot) {

                    if(snapshot.hasData) {
                      _friendsList = snapshot.data;

                      return Container(
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(), 
                          child: _searchResult.length != 0 || controller.text.isNotEmpty
                          ? ListView.builder(
                            padding: EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 12.0),
                            itemCount: _searchResult.length,
                            itemBuilder: (context, i) {
                              return _friendTile(_searchResult[i]); 
                            }
                          )
                          : ListView.builder(
                            padding: EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 12.0),
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
                      return Center(child: CircularProgressIndicator());
                    }
                  }
                )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  elevation: 8.0,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, 
                            color: DynamicTheme.of(context).data.primaryColor
                          ),
                        ),
                        SizedBox(width: Constants.defaultSpacing),
                        Icon(Icons.search, color: Colors.black54),
                      ],
                    ),
                    title: TextField(
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
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(icon: Icon(Icons.cancel), onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
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
}