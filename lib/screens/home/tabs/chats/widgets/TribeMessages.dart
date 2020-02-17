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
          margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 35.0,
                    backgroundColor: Colors.red,
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Daniel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Text(message.message,
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(formattedTime,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Visibility(
                    visible: !isMe,
                    child: Container(
                      width: 40.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: DynamicTheme.of(context).data.primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      alignment: Alignment.center,
                      child: Text('New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: (currentTribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: (currentTribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.3),
                                blurRadius: 10,
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
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: <Widget>[
                                    FirestoreAnimatedList(
                                      reverse: false,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.symmetric(horizontal: 6.0),
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
