import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/PostTile.dart';
import 'package:tribes/services/database.dart';

class Posts extends StatelessWidget {
  final Tribe tribe;
  Posts({this.tribe});

  @override
  Widget build(BuildContext context) {
    print('Building Posts()...');
    print('Tribe id: ${tribe.id}');

    return Container(
      child: FirestoreAnimatedList(
        padding: EdgeInsets.only(bottom: 80.0),
        query: DatabaseService().posts(tribe.id),
        itemBuilder: (
          BuildContext context,
          DocumentSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) =>
            FadeTransition(
          opacity: animation,
          child: PostTile(
            post: Post.fromSnapshot(snapshot), 
            tribeColor: tribe.color, 
            index: index
          ),
        ),
        emptyChild: Center(
          child: Text('No posts created yet!'),
        ),
      ),
    );
  }
}
