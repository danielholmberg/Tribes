import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tribes/core/tribe/widgets/post_item.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostList extends StatelessWidget {
  final Tribe tribe;
  final Function onEditPostPress;
  final Function onEmptyTextPress;
  PostList({@required this.tribe, this.onEditPostPress, this.onEmptyTextPress});

  final ScrollController controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;
    print('Building Posts(${tribe.id})...');

    _buildEmptyListWidget() {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Be the first to',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.normal),
            ),
            GestureDetector(
              onTap: onEmptyTextPress,
              child: Text(
                ' add a post',
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20.0,
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    _scrollToNewPostIfAuthor(QuerySnapshot snapshot) {
      List<DocumentChange> listChanges = snapshot.docChanges;
      if (listChanges.isNotEmpty &&
          listChanges.first.type == DocumentChangeType.added &&
          snapshot.docs.first.data()['author'] == currentUser.id) {
        if (controller.hasClients)
          controller.animateTo(0,
              duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
      }
    }

    return Container(
      child: FirestoreAnimatedList(
        controller: controller,
        padding: EdgeInsets.only(
          top: Constants.defaultPadding,
          bottom: Platform.isIOS ? 8.0 : 4.0,
        ),
        query: DatabaseService().posts(tribe.id),
        onLoaded: _scrollToNewPostIfAuthor,
        itemBuilder: (
          BuildContext context,
          DocumentSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) {
          return FadeTransition(
            opacity: animation,
            child: PostTile(
              post: Post.fromSnapshot(snapshot),
              tribeColor: tribe.color,
            ),
          );
        },
        emptyChild: _buildEmptyListWidget(),
      ),
    );
  }
}
