import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/core/chat/widgets/chat_messages.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/user_avatar.dart';

// ToDo - Change to Stateless widget and move all state and business-logic to related [viewName]_view_model.dart file.

class ChatRoomView extends StatefulWidget {

  final String roomID;
  final Tribe currentTribe;
  final List<dynamic> members;
  final bool reply;
  ChatRoomView({
    @required this.roomID, 
    this.currentTribe, 
    this.members, 
    this.reply,
  });

  @override
  _ChatRoomViewState createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {

  String message = '';
  final TextEditingController controller = new TextEditingController();
  FocusNode textFieldFocus;

  @override
  void initState() {
    textFieldFocus = new FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    textFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;
    print('Building ChatRoom(${widget.roomID})...');

    ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft), 
          color: Constants.buttonIconColor, 
          onPressed: () => Navigator.of(context).pop()
        ),
        title: widget.members != null ? StreamBuilder<MyUser>(
          stream: DatabaseService().userData(widget.members.where((memberID) => memberID != currentUser.id).toList()[0]),
          builder: (context, snapshot) {                
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: snapshot.hasData,
                  child: UserAvatar(
                    currentUserID: currentUser.id,
                    user: snapshot.data, 
                    color: Colors.white,
                    radius: 14,
                    onlyAvatar: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ),
                AutoSizeText(snapshot.hasData ? snapshot.data.username : 'No name',
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
      );
    }

    _buildMessageComposer() {
      return Container(
        constraints: BoxConstraints(minHeight: 70),
        padding: EdgeInsets.only(top: 8.0, bottom: Platform.isIOS ? (textFieldFocus.hasFocus ? 8.0 : 24.0) : 8.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.paperclip),
              iconSize: Constants.defaultIconSize,
              color: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor,
              onPressed: () => Fluttertoast.showToast(
                msg: 'Coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              ),
            ),
            Expanded(
              child: TextField(
                focusNode: textFieldFocus,
                controller: controller,
                autofocus: widget.reply != null ? widget.reply : false,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 10,
                cursorRadius: Radius.circular(1000),
                cursorColor: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor, width: 2.0),
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
              color: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor,
              onPressed: message.isEmpty ? null : () {
                controller.clear();
                FocusScope.of(context).unfocus();
                DatabaseService().sendChatMessage(widget.roomID, currentUser.id, message);
                setState(() => message = '');
              },
            ),
          ],
        ),
      );
    }

    return Container(
      color: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: widget.currentTribe != null ? widget.currentTribe.color : themeData.primaryColor,
          appBar: _buildAppBar(),
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
                      child: ChatMessages(
                        roomID: widget.roomID,
                        color: widget.currentTribe != null ? widget.currentTribe.color : Constants.primaryColor,
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
