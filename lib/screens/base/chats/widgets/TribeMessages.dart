import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/chats/screens/ChatRoom.dart';
import 'package:tribes/screens/base/chats/Chats.dart';
import 'package:tribes/screens/base/chats/widgets/ChatMessages.dart';
import 'package:tribes/services/database.dart';
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
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.black26, width: 3.0),
            boxShadow: [Constants.defaultBoxShadow],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Container(
                    color: DynamicTheme.of(context).data.backgroundColor,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ChatMessages(
                          roomID: currentTribe.id,
                          color: currentTribe.color,
                          isTribePreview: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: (currentTribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
                child: AutoSizeText(
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
                padding: EdgeInsets.only(top: 4.0, bottom: 72.0),
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
