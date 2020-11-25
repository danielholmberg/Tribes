import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/material.dart';
import 'package:tribes/core/chat/widgets/chat_message_item.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class ChatMessages extends StatelessWidget {
  final String roomID;
  final Color color;
  final bool isTribePreview;
  ChatMessages({
    this.roomID,
    this.color = Constants.primaryColor,
    this.isTribePreview = false,
  });

  final ScrollController controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;

    Query query = isTribePreview
        ? DatabaseService().fiveLatestMessages(roomID)
        : DatabaseService().allMessages(roomID);

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
      if (listChanges.isNotEmpty &&
          listChanges.first.type == DocumentChangeType.added &&
          snapshot.docs.first.data()['author'] == currentUser.id) {
        if (controller.hasClients)
          controller.animateTo(
            0,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeIn,
          );
      }
    }

    return Container(
      child: FirestoreAnimatedList(
        controller: controller,
        physics: isTribePreview
            ? NeverScrollableScrollPhysics()
            : ClampingScrollPhysics(),
        reverse: true,
        shrinkWrap: false,
        padding: EdgeInsets.symmetric(vertical: isTribePreview ? 2.0 : 4.0),
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
        emptyChild: _buildEmptyListWidget(),
      ),
    );
  }
}
