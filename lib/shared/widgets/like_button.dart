import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_stroked_text.dart';

enum LikeButtonTextPosition {
  LEFT,
  RIGHT
}

class LikeButton extends StatelessWidget {
  final MyUser currentUser;
  final String postID;
  final Color color;
  final bool withNumberOfLikes;
  final bool fab;
  final Color backgroundColor;
  final bool mini;
  final Function onLiked;
  final LikeButtonTextPosition numberOfLikesPosition;
  LikeButton({
    @required this.currentUser, 
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
    bool likedByUser = currentUser.likedPosts.contains(postID);
    bool likesOnLeftSide = numberOfLikesPosition == LikeButtonTextPosition.LEFT;

    _onPress() {
      if (likedByUser) {
        print('User ${currentUser.id} unliked Post $postID');
        DatabaseService().unlikePost(currentUser.id, postID);
      } else {
        print('User ${currentUser.id} liked Post $postID');
        DatabaseService().likePost(currentUser.id, postID);
        
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
        heroTag: '$postID-likeButtonFAB',
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
              text: numberOfLikes != null ? NumberFormat.compact().format(numberOfLikes) : '',
              minFontSize: 10,
              fontWeight: FontWeight.bold,
              strokeColor: Colors.black54,
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