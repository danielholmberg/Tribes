import 'package:flutter/material.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostTile extends StatelessWidget {

  final Post post;
  PostTile({ this.post });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Constants.mediumPadding),
      child: Card(
        margin: EdgeInsets.fromLTRB(
          Constants.largePadding, 
          Constants.mediumPadding, 
          Constants.largePadding, 
          0.0
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.pink,
          ),
          title: Text(post.title),
          subtitle: Text(post.content),
        ),
      ),
    );
  }
}