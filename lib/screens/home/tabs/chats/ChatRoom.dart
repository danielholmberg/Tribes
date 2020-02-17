import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Message.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class ChatRoom extends StatefulWidget {

  final String roomID;
  final Tribe currentTribe;
  final List<dynamic> members;
  final bool reply;
  ChatRoom({this.roomID, this.currentTribe, this.members, this.reply});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  String message = '';
  final TextEditingController controller = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribeMessages()...');
    print('Current user ${currentUser.toString()}');

    final String recieverID = widget.members.where((memberID) => memberID != currentUser.uid).toList()[0];

    _buildMessage(Message message) {
      bool isMe = message.senderID == currentUser.uid;

      DateTime created = DateTime.fromMillisecondsSinceEpoch(message.created); 
      String formattedTime = DateFormat('kk:mm').format(created);

      final Container msg = Container(
        width: MediaQuery.of(context).size.width * 0.6,
        margin: isMe 
          ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: MediaQuery.of(context).size.width * 0.4, right: 6.0) 
          : EdgeInsets.only(top: 8.0, bottom: 8.0, left: 6.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe 
          ? DynamicTheme.of(context).data.primaryColor.withOpacity(0.8)
          : (widget.currentTribe != null ? widget.currentTribe.color : Colors.grey).withOpacity(0.8),
          borderRadius: isMe 
            ? BorderRadius.only(
              topRight: Radius.circular(20.0),
              topLeft: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
            )
            : BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message.message,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'TribesRounded',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(formattedTime,
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'TribesRounded',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            )
          ],
        ),
      );

      if(isMe) {
        return msg;
      }

      return Row(
        children: <Widget>[
          msg, 
          IconButton(
            icon: Icon(Icons.favorite_border), //TODO: message.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
            iconSize: 30.0,
            color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor, //TODO: message.isLiked ? DynamicTheme.of(context).data.primaryColor : Colors.blueGrey,
            onPressed: () {
              Fluttertoast.showToast(
                msg: 'Coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
        ],
      );
    }

    _buildMessageComposer() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        height: 70.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo),
              iconSize: 25.0,
              color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
              onPressed: () {print('Picking image to attach...');},
            ),
            SizedBox(width: Constants.defaultPadding),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: widget.reply != null ? widget.reply : false,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor, width: 2.0),
                  ),
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontFamily: 'TribesRounded',
                  )
                ),
                onChanged: (val) => setState(() => message = val),
              ),
            ),
            SizedBox(width: Constants.defaultPadding),
            IconButton(
              icon: Icon(Icons.send),
              iconSize: 25.0,
              color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
              onPressed: () {
                if(message.isNotEmpty) {
                  controller.clear();
                  FocusScope.of(context).unfocus();
                  DatabaseService().sendMessage(widget.roomID, currentUser.uid, message);
                  listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                }
              },
            ),
          ],
        ),
      );
    }
    
    return Container(
      color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: widget.members != null ? StreamBuilder<UserData>(
              stream: DatabaseService().userData(recieverID),
              builder: (context, snapshot) {                
                return AutoSizeText(snapshot.hasData ? snapshot.data.name : 'No name',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 10.0,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TribesRounded',
                  ),
                );
              }
            ) 
            : AutoSizeText(widget.currentTribe != null ? widget.currentTribe.name : 'No name',
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 10.0,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'TribesRounded',
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.more_horiz),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: () {print('Clicked on More button');},
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      child: FirestoreAnimatedList(
                        controller: listScrollController,
                        reverse: true,
                        shrinkWrap: false,
                        duration: Duration(milliseconds: 500),
                        query: DatabaseService().allMessages(widget.roomID),
                        itemBuilder: (
                          BuildContext context,
                          DocumentSnapshot snapshot,
                          Animation<double> animation,
                          int index,
                        ) => FadeTransition(
                          opacity: animation,
                          child: _buildMessage(Message.fromSnapshot(snapshot)),
                        ),
                        emptyChild: Center(
                          child: Text('No messages',
                            style: TextStyle(
                              fontFamily: 'TribesRounded',
                              color: Colors.black26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildMessageComposer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
