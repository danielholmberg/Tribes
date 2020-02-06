import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

Widget postedDateTime(int timestamp, {double fontSize = Constants.timestampFontSize}) {
  DateTime created = DateTime.fromMillisecondsSinceEpoch(timestamp); 
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(created);
  
  return Text(formattedDate,
    textAlign: TextAlign.center, 
    style: TextStyle(
      color: Colors.black54,
      fontSize: fontSize,
    ),
  );
}

IconButton likeButton(UserData user, String postID, Color color) {
  bool likedByUser = user.likedPosts.contains(postID);
  return IconButton(
      splashColor: Colors.transparent,
      color: Constants.backgroundColor,
      icon: Icon(likedByUser ? Icons.favorite : Icons.favorite_border, 
        color: color.withOpacity(likedByUser ? 1.0 : 0.6),
      ),
      onPressed: () async {
        if (likedByUser) {
          print('User ${user.uid} unliked Post $postID');
          await DatabaseService().unlikePost(user.uid, postID);
        } else {
          print('User ${user.uid} liked Post $postID');
          await DatabaseService().likePost(user.uid, postID);
        }
      },
    );
}
