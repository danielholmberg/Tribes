import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Message.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/ChatRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeMessages extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribeMessages()...');
    print('Current user ${currentUser.toString()}');

    _messageListItem(Message message, Tribe currentTribe) {
      bool isMe = message.senderID == currentUser.uid;

      DateTime created = DateTime.fromMillisecondsSinceEpoch(message.created); 
      String formattedTime = DateFormat('kk:mm').format(created);

      return StreamBuilder<Object>(
        stream: DatabaseService().userData(message.senderID),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            UserData sender = snapshot.data;

            return GestureDetector(
              onTap: () => Navigator.push(context, CustomPageTransition(
                  type: CustomPageTransitionType.chatRoom, 
                  duration: Constants.pageTransition600, 
                  child: StreamProvider<UserData>.value(
                    value: DatabaseService().currentUser(currentUser.uid), 
                    child: ChatRoom(roomID: currentTribe.id, currentTribe: currentTribe),
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
                margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  leading: userAvatar(sender, size: Constants.chatMessageAvatarSize, onlyAvatar: true),
                  title: Text(sender.name,
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
                      text: formattedTime.isNotEmpty ? formattedTime : 'No message',
                      style: TextStyle(
                        color: formattedTime.isNotEmpty ? Colors.black : Colors.black26,
                        fontFamily: 'TribesRounded',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${isMe ? ' You: ' : '  '}',
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: message.message,
                          style: TextStyle(
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: SizedBox(width: Constants.defaultSpacing),
                ),
              ),
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
    
    return Expanded(
      child: StreamBuilder<List<Tribe>>(
        stream: DatabaseService().joinedTribes(currentUser.uid),
        builder: (context, snapshot) {

          if(snapshot.hasData) {
            List<Tribe> joinedTribes = snapshot.data;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
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
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: GridView.builder(
                    padding: EdgeInsets.only(top: 4.0, bottom: 80.0),
                    itemCount: joinedTribes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.2
                    ),
                    itemBuilder: (context, index) {
                      Tribe currentTribe = joinedTribes[index];

                      return Container(
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: (currentTribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.8),
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            AutoSizeText(
                              currentTribe.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 10.0,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'TribesRounded',
                              ),
                            ),
                            SizedBox(height: Constants.smallSpacing),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: DynamicTheme.of(context).data.backgroundColor,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0)
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      FirestoreAnimatedList(
                                        reverse: false,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(vertical: 6.0),
                                        query: DatabaseService().fiveLatestMessages(currentTribe.id),
                                        itemBuilder: (
                                          BuildContext context,
                                          DocumentSnapshot snapshot,
                                          Animation<double> animation,
                                          int index,
                                        ) => FadeTransition(
                                          opacity: animation,
                                          child: _messageListItem(Message.fromSnapshot(snapshot), currentTribe),
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
                                      SizedBox(height: Constants.smallSpacing),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(context, 
                                            CustomPageTransition(
                                              type: CustomPageTransitionType.chatRoom, 
                                              duration: Constants.pageTransition600, 
                                              child: StreamProvider<UserData>.value(
                                                value: DatabaseService().currentUser(currentUser.uid), 
                                                child: ChatRoom(roomID: currentTribe.id, currentTribe: currentTribe),
                                              ),
                                            )
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: currentTribe.color.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(20.0),
                                              border: Border.all(color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0)
                                            ),
                                            child: Text('See all', 
                                              style: TextStyle(
                                                fontFamily: 'TribesRounded',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if(snapshot.hasError){
            print('Error retrieving joined Tribes: ${snapshot.error.toString()}');
            return Center(child: Text('Unable to retrieve Tribes'));
          } else {
            return Center(
              child: Text('No joined Tribes',
                style: TextStyle(
                  fontFamily: 'TribesRounded',
                  color: Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
        }
      ),
    );
  }
}
