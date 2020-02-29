import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class LikeButton extends StatelessWidget {
  final UserData user;
  final String postID;
  final Color color;
  LikeButton({this.user, this.postID, this.color});

  @override
  Widget build(BuildContext context) {
    bool likedByUser = user.likedPosts.contains(postID);
    return IconButton(
        splashColor: Colors.transparent,
        color: Constants.backgroundColor,
        icon: CustomAwesomeIcon(icon: likedByUser ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, 
          color: color,
        ),
        onPressed: () {
          if (likedByUser) {
            print('User ${user.uid} unliked Post $postID');
            DatabaseService().unlikePost(user.uid, postID);
          } else {
            print('User ${user.uid} liked Post $postID');
            DatabaseService().likePost(user.uid, postID);
          }
        },
      );
  }
}