import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostTile extends StatelessWidget {

  final Post post;
  PostTile({ this.post });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      color: Constants.postBackgroundColor,
      margin: EdgeInsets.fromLTRB(
        Constants.largePadding,
        Constants.largePadding,
        Constants.largePadding,
        0.0
      ),
      child: InkWell(
        splashColor: Constants.tribesColor.withAlpha(30),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Constants.postBackgroundColor,
              contentPadding: EdgeInsets.all(16.0),
              content: Hero(
                tag: post.id,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(post.title, style: DynamicTheme.of(context).data.textTheme.subhead),
                      Text(post.content, style: DynamicTheme.of(context).data.textTheme.body1)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Hero(
          tag: post.id,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(post.title, style: DynamicTheme.of(context).data.textTheme.subhead),
                Text(post.content, style: DynamicTheme.of(context).data.textTheme.body1)
              ],
            ),
          ),
        ),
      ),
    );
  }
}