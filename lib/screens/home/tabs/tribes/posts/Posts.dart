import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/PostTile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Posts extends StatelessWidget {
  
  final String tribeID;
  Posts({this.tribeID});

  @override
  Widget build(BuildContext context) {
    print('Building Posts()...');
    print('Tribe id: $tribeID');

    return Container(
      child: Stack(
        children: <Widget>[
          FirestoreAnimatedList(
            padding: EdgeInsets.only(bottom: 80.0),
            query: DatabaseService().posts(tribeID),
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot snapshot,
              Animation<double> animation,
              int index,
            ) =>
                FadeTransition(
              opacity: animation,
              child: PostTile(post: Post.fromSnapshot(snapshot)),
            ),
            emptyChild: Center(
              child: Text('No post created yet!'),
            ),
          ),
        ],
      ),
    );
  }
}
