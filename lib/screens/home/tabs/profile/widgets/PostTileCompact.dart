import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/EditPost.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostTileCompact extends StatelessWidget {
  final Post post;
  PostTileCompact({this.post});

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    _postTileMain() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0),
            child: Text(post.title,
              style: TextStyle(
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * Constants.postTileCompactScaleFactor,
            padding: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 4.0),
            child: Text(post.content,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ),
          post.images.isEmpty ? SizedBox.shrink() : ImageCarousel(images: post.images, small: true),
        ],
      );
    }

    return InkWell(
        splashColor: Constants.tribesColor.withAlpha(30),
        onTap: () {
          if(post.author == currentUser.uid) {
            Navigator.push(context, CustomPageTransition(
              type: CustomPageTransitionType.postDetails, 
              duration: Constants.pageTransition600, 
              child: StreamProvider<UserData>.value(
                value: DatabaseService().currentUser(currentUser.uid), 
                child: EditPost(post, DynamicTheme.of(context).data.primaryColor, Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft),
              ),
            ));
          }
        },
        child: Container(
          margin: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: DynamicTheme.of(context).data.backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black54, //DynamicTheme.of(context).data.primaryColor.withOpacity(0.6),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ]
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(11.0), bottomRight: Radius.circular(11.0)),
                      child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _postTileMain(),
              ],
            ),
          )
      ),
    );
  }
}
