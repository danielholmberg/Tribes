import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Message.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/utils.dart';

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

    _buildMessage(Message message) {
      bool isMe = message.senderID == currentUser.uid;

      DateTime created = DateTime.fromMillisecondsSinceEpoch(message.created); 
      String formattedTime = DateFormat('kk:mm').format(created);

      final Container msg = Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        margin: EdgeInsets.all(6.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isMe 
          ? DynamicTheme.of(context).data.primaryColor.withOpacity(0.7)
          : (widget.currentTribe != null ? widget.currentTribe.color : Colors.grey).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20.0)
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
          ],
        ),
      );

      if(isMe) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(formattedTime,
              style: TextStyle(
                color: Colors.black26,
                fontFamily: 'TribesRounded',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                msg,
                StreamBuilder<UserData>(
                  stream: DatabaseService().userData(message.senderID),
                  builder: (context, snapshot) {
                    return snapshot.hasData 
                    ? userAvatar(
                      user: snapshot.data, 
                      padding: const EdgeInsets.symmetric(vertical: 6.0), 
                      radius: 14, 
                      onlyAvatar: true
                    ) : SizedBox.shrink();
                  }
                ),
              ],
            ),
            SizedBox(width: Constants.defaultPadding)
          ],
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(width: Constants.defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder<UserData>(
                stream: DatabaseService().userData(message.senderID),
                builder: (context, snapshot) {
                  return snapshot.hasData 
                  ? userAvatar(
                    user: snapshot.data, 
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    color: widget.currentTribe != null ? widget.currentTribe.color : Colors.grey, 
                    radius: 14, 
                    onlyAvatar: true
                  ) : SizedBox.shrink();
                }
              ),
              msg, 
            ],
          ),
          Text(formattedTime,
            style: TextStyle(
              color: Colors.black26,
              fontFamily: 'TribesRounded',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    _buildMessageComposer() {
      return Container(
        constraints: BoxConstraints(minHeight: 70),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.paperclip),
              iconSize: Constants.defaultIconSize,
              color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
              onPressed: () => Fluttertoast.showToast(
                msg: 'Coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: widget.reply != null ? widget.reply : false,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 10,
                cursorColor: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
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
            IconButton(
              icon: Icon(FontAwesomeIcons.solidPaperPlane),
              iconSize: Constants.defaultIconSize,
              color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
              onPressed: message.isEmpty ? null : () {
                controller.clear();
                FocusScope.of(context).unfocus();
                DatabaseService().sendMessage(widget.roomID, currentUser.uid, message);
                listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
              },
            ),
          ],
        ),
      );
    }
    
    return Container(
      color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft), 
              color: Constants.buttonIconColor, 
              onPressed: () => Navigator.of(context).pop()
            ),
            title: widget.members != null ? StreamBuilder<UserData>(
              stream: DatabaseService().userData(widget.members.where((memberID) => memberID != currentUser.uid).toList()[0]),
              builder: (context, snapshot) {                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: snapshot.hasData,
                      child: userAvatar(
                        user: snapshot.data, 
                        color: Colors.white,
                        onlyAvatar: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                    AutoSizeText(snapshot.hasData ? snapshot.data.name : 'No name',
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
                  ],
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
                icon: Icon(FontAwesomeIcons.ellipsisH),
                iconSize: Constants.defaultIconSize,
                color: Colors.white,
                onPressed: () => Fluttertoast.showToast(
                  msg: 'Coming soon!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                ),
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
