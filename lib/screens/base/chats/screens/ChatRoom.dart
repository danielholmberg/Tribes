import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/chats/widgets/ChatMessages.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/UserAvatar.dart';

class ChatRoom extends StatefulWidget {

  final String roomID;
  final Tribe currentTribe;
  final List<dynamic> members;
  final bool reply;
  ChatRoom({
    @required this.roomID, 
    this.currentTribe, 
    this.members, 
    this.reply,
  });

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  String message = '';
  final TextEditingController controller = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
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
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribeMessages()...');
    print('Current user ${currentUser.toString()}');

    _buildAppBar() {
      return AppBar(
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
                  child: UserAvatar(
                    currentUserID: currentUser.uid,
                    user: snapshot.data, 
                    color: Colors.white,
                    radius: 14,
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
              color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
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
                cursorColor: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: widget.currentTribe != null ? widget.currentTribe.color : DynamicTheme.of(context).data.primaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
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
                DatabaseService().sendChatMessage(widget.roomID, currentUser.uid, message);
                setState(() => message = '');
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
                        scrollController: listScrollController,
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
