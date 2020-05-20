import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/widgets/PostTile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Posts extends StatelessWidget {
  final Tribe tribe;
  final Function onEditPostPress;
  final Function onEmptyTextPress;
  Posts({@required this.tribe, this.onEditPostPress, this.onEmptyTextPress});

  final ScrollController controller = new ScrollController();
  
  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Posts(${tribe.id})...');

    _buildEmptyListWidget() {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Be the first to',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 18.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal
              ),
            ),
            GestureDetector(
              onTap: onEmptyTextPress,
              child: Text(' add a post',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 20.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      child: FirestoreAnimatedList(
        controller: controller,
        padding: EdgeInsets.only(top: Constants.defaultPadding, bottom: Platform.isIOS ? 8.0 : 4.0),
        query: DatabaseService().posts(tribe.id),
        onLoaded: (snapshot) => currentUser != null 
          ? ((snapshot.documentChanges.first.type == DocumentChangeType.added && snapshot.documents.first.data['author'] == currentUser.uid) 
            ? controller.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeIn) 
            : null)
          : null,
        itemBuilder: (
          BuildContext context,
          DocumentSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) => FadeTransition(
          opacity: animation,
          child: PostTile(
            post: Post.fromSnapshot(snapshot), 
            tribeColor: tribe.color, 
          ),
        ),
        emptyChild: _buildEmptyListWidget(),
      ),
    );
  }
}
