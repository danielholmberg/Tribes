import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/material.dart';
import 'package:tribes/core/chat/widgets/chat_message_item.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/Loading.dart';

class ChatMessages extends StatelessWidget {
  final String roomID;
  final Color color;
  ChatMessages({
    this.roomID,
    this.color = Constants.primaryColor
  });

  final ScrollController controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;

    Query query = DatabaseService().allMessages(roomID);

    _buildEmptyListWidget() {
      return Center(
        child: Text(
          'No messages',
          style: TextStyle(
            fontFamily: 'TribesRounded',
            color: Colors.black26,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    _scrollToNewMessageIfAuthor(QuerySnapshot snapshot) {
      List<DocumentChange> listChanges = snapshot.docChanges;

      try {
        Map<String, dynamic> data = snapshot.docs.first.data();
        if (listChanges.isNotEmpty &&
            listChanges.first.type == DocumentChangeType.added &&
            data['author'] == currentUser.id) {
          if (controller.hasClients)
            controller.animateTo(
              0,
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeIn,
            );
        }
      } on StateError catch(error) {
        print('Failed on scrolling to new message with error: $error');
      }
    }

    return Container(
      child: FirestoreAnimatedList(
        controller: controller,
        physics: ClampingScrollPhysics(),
        reverse: true,
        shrinkWrap: false,
        padding: EdgeInsets.symmetric(vertical: 4.0),
        duration: Duration(milliseconds: 500),
        onLoaded: _scrollToNewMessageIfAuthor,
        query: query,
        itemBuilder: (
          BuildContext context,
          DocumentSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) =>
            FadeTransition(
          opacity: animation,
          child: ChatMessageItem(
            message: Message.fromSnapshot(snapshot),
            color: color,
          ),
        ),
        defaultChild: Loading(color: color),
        emptyChild: _buildEmptyListWidget(),
        errorChild: _buildEmptyListWidget(),
      ),
    );
  }
}
