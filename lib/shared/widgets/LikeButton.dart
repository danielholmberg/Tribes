import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomStrokedText.dart';

enum LikeButtonTextPosition {
  LEFT,
  RIGHT
}

class LikeButton extends StatelessWidget {
  final UserData user;
  final String postID;
  final Color color;
  final bool withNumberOfLikes;
  final bool fab;
  final Color backgroundColor;
  final bool mini;
  final Function onLiked;
  final LikeButtonTextPosition numberOfLikesPosition;
  LikeButton({
    @required this.user, 
    @required this.postID, 
    this.color,
    this.withNumberOfLikes = false,
    this.fab = false,
    this.backgroundColor = Constants.primaryColor,
    this.mini = false,
    this.onLiked,
    this.numberOfLikesPosition = LikeButtonTextPosition.LEFT,
  });

  @override
  Widget build(BuildContext context) {
    bool likedByUser = user.likedPosts.contains(postID);
    bool likesOnLeftSide = numberOfLikesPosition == LikeButtonTextPosition.LEFT;

    _onPress() {
      if (likedByUser) {
        print('User ${user.uid} unliked Post $postID');
        DatabaseService().unlikePost(user.uid, postID);
      } else {
        print('User ${user.uid} liked Post $postID');
        DatabaseService().likePost(user.uid, postID);
        
        if(onLiked != null) {
          onLiked();
        }
      }
    }

    _buildIcon() {
      return CustomAwesomeIcon(
        icon: likedByUser ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, 
        color: color,
        size: fab && mini ? 16 : 24,
      );
    }

    _buildFAB() {
      return FloatingActionButton(
        mini: mini,
        backgroundColor: backgroundColor,
        onPressed: _onPress,
        child: _buildIcon(),
      );
    }

    _buildIconButton() {
      return IconButton(
        splashColor: Colors.transparent,
        color: backgroundColor,
        onPressed: _onPress,
        icon: _buildIcon(),
      );
    }

    _buildNumberOfLikesText() {
      return StreamBuilder<int>(
        stream: DatabaseService().numberOfLikes(postID),
        builder: (context, snapshot) {
          int numberOfLikes = snapshot.data;

          if(snapshot.hasError) {
            print('Error retrieving number of likes for Post ($postID): ${snapshot.error.toString()}');
          }

          return AnimatedOpacity(
            opacity: numberOfLikes != null ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: CustomStrokedText(
              text: '$numberOfLikes',
              minFontSize: 10,
              fontWeight: FontWeight.bold,
              strokeColor: backgroundColor,
              strokeWidth: 2.0,
            ),
          );
        }
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: withNumberOfLikes && likesOnLeftSide,
          child: _buildNumberOfLikesText(),
        ),
        Visibility(
          visible: withNumberOfLikes && likesOnLeftSide,
          child: SizedBox(width: 4.0),
        ),

        fab ? _buildFAB() : _buildIconButton(),
        
        Visibility(
          visible: withNumberOfLikes && !likesOnLeftSide,
          child: SizedBox(width: 4.0),
        ),
        Visibility(
          visible: withNumberOfLikes && !likesOnLeftSide,
          child: _buildNumberOfLikesText(),
        ),
      ],
    );
  }
}