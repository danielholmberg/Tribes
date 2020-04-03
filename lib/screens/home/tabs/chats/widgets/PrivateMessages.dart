import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Chat.dart';
import 'package:tribes/models/Message.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/ChatRoom.dart';
import 'package:tribes/screens/home/tabs/chats/Chats.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/UserAvatar.dart';

class PrivateMessages extends StatelessWidget {
  static const routeName = Chats.routeName + '/privateMessages';

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PrivateMessages()...');
    print('Current user ${currentUser.toString()}');

    _chatRoomListItem(ChatData chatData) {
      String notMyID = chatData.members.where((memberID) => memberID != currentUser.uid).toList()[0];

      return StreamBuilder<UserData>(
        stream: DatabaseService().userData(notMyID),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            UserData reciever = snapshot.data;

            return StreamBuilder<Message>(
              stream: DatabaseService().mostRecentMessage(chatData.id),
              builder: (context, snapshot) {
                String message;
                bool isMe = false;
                String formattedTime = '';

                if(snapshot.hasData) {
                  message = snapshot.data.message;
                  isMe = snapshot.data.senderID == currentUser.uid;

                  DateTime created = DateTime.fromMillisecondsSinceEpoch(snapshot.data.created); 
                  formattedTime = DateFormat('kk:mm').format(created);
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => Navigator.push(context, 
                          CustomPageTransition(
                            type: CustomPageTransitionType.chatRoom, 
                            duration: Constants.pageTransition600, 
                            child: StreamProvider<UserData>.value(
                              value: DatabaseService().currentUser(currentUser.uid), 
                              child: ChatRoom(roomID: chatData.id, members: chatData.members),
                            ),
                          )
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: DynamicTheme.of(context).data.backgroundColor,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 2),
                              ),
                            ]
                          ),
                          margin: EdgeInsets.only(right: isMe || message == null ? 0.0 : 22.0),
                          padding: EdgeInsets.only(right: isMe || message == null ? 6.0 : 22.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                            leading: UserAvatar(currentUserID: currentUser.uid, user: reciever, radius: Constants.chatMessageAvatarSize, onlyAvatar: true),
                            title: Text(reciever.name,
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            subtitle: RichText(
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              text: TextSpan(
                                text: '${isMe ? 'You: ' : ''}',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'TribesRounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                children: <TextSpan>[
                                  message != null ? 
                                  TextSpan(
                                    text: message,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'TribesRounded',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ) :
                                  TextSpan(
                                    text:'No messages',
                                    style: TextStyle(
                                      fontFamily: 'TribesRounded',
                                      color: Colors.black26,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(formattedTime ?? '',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !isMe && message != null,
                        child: Positioned(
                          right: 0,
                          child: FloatingActionButton(
                            heroTag: 'replyButton-${reciever.uid}',
                            elevation: 4.0,
                            mini: true,
                            child: CustomAwesomeIcon(icon: FontAwesomeIcons.reply, size: Constants.smallIconSize),
                            backgroundColor: DynamicTheme.of(context).data.primaryColor,
                            onPressed: () => Navigator.push(context, 
                              CustomPageTransition(
                                type: CustomPageTransitionType.chatRoom, 
                                duration: Constants.pageTransition600, 
                                child: StreamProvider<UserData>.value(
                                  value: DatabaseService().currentUser(currentUser.uid), 
                                  child: ChatRoom(roomID: chatData.id, members: chatData.members, reply: true),
                                ),
                              )
                            ),
                          ),
                        ),
                      ),
                    ]
                  )
                );
              }
            );
          } else if(snapshot.hasError) {
            print('Error retrieving user data: ${snapshot.error.toString()}');
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: FirestoreAnimatedList(
          padding: EdgeInsets.only(top: 12.0, bottom: 80.0),
          reverse: false,
          shrinkWrap: true,
          query: DatabaseService().privateChatRooms(currentUser.uid),
          itemBuilder: (
            BuildContext context,
            DocumentSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) => FadeTransition(
            opacity: animation,
            child: _chatRoomListItem(ChatData.fromSnapshot(snapshot)),
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
    );
  }
}
