import 'package:flutter/material.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/user_avatar.dart';

class ChatMessageItem extends StatefulWidget {
  final Message message;
  final Color color;
  ChatMessageItem({
    @required this.message,
    this.color = Constants.primaryColor,
  });

  @override
  _ChatMessageItemState createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;
    bool isMe = widget.message.senderID == currentUser.id;

    final Container msg = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      margin: EdgeInsets.all(4.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isMe 
        ? widget.color.withOpacity(0.7)
        : Colors.grey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.message.message,
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
          Text(widget.message.formattedTime(),
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
              StreamBuilder<MyUser>(
                stream: DatabaseService().userData(widget.message.senderID),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    print('Error retrieving sender data: ${snapshot.error.toString()}');
                  }

                  return UserAvatar(
                    currentUserID: currentUser.id,
                    user: snapshot.data, 
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    color: widget.color,  
                    radius: 10, 
                    strokeWidth: 1.0,
                    onlyAvatar: true
                  );
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
            StreamBuilder<MyUser>(
              stream: DatabaseService().userData(widget.message.senderID),
              builder: (context, snapshot) {
                if(snapshot.hasError) {
                  print('Error retrieving sender data: ${snapshot.error.toString()}');
                }

                return UserAvatar(
                  currentUserID: currentUser.id,
                  user: snapshot.data, 
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  color: widget.color, 
                  radius: 10, 
                  strokeWidth: 1.0,
                  onlyAvatar: true
                );
              }
            ),
            msg, 
          ],
        ),
        Text(widget.message.formattedTime(),
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
}