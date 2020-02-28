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
import 'package:tribes/screens/home/tabs/chats/Chats.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeMessages extends StatelessWidget {
  static const routeName = Chats.routeName + '/tribeMessages';
  
  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribeMessages()...');
    print('Current user ${currentUser.toString()}');

    _buildMessage(Message message, Tribe currentTribe) {
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
          : currentTribe.color.withOpacity(0.7),
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    color: currentTribe.color, 
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

    _buildTribeTile(Tribe currentTribe) {
      return GestureDetector(
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
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
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
                                child: _buildMessage(Message.fromSnapshot(snapshot), currentTribe),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Text('See all', 
                  style: TextStyle(
                    fontFamily: 'TribesRounded',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: StreamBuilder<List<Tribe>>(
          stream: DatabaseService().joinedTribes(currentUser.uid),
          builder: (context, snapshot) {

            if(snapshot.hasData) {
              List<Tribe> joinedTribes = snapshot.data;
              
              return GridView.builder(
                padding: EdgeInsets.only(top: 4.0, bottom: 80.0),
                itemCount: joinedTribes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.5
                ),
                itemBuilder: (context, index) {
                  Tribe currentTribe = joinedTribes[index];

                  return _buildTribeTile(currentTribe);
                },
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
      ),
    );
  }
}
