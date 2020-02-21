import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

Widget postedDateTime(int timestamp, 
{double fontSize = Constants.timestampFontSize,
Color color = Constants.primaryColor}) {
  DateTime created = DateTime.fromMillisecondsSinceEpoch(timestamp); 
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(created);
  
  return Text(formattedDate,
    textAlign: TextAlign.center, 
    style: TextStyle(
      color: color.withOpacity(0.8),
      fontFamily: 'TribesRounded',
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
        color: color,
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

Widget userAvatar(UserData user, {
  Color color: Constants.primaryColor, 
  Future addressFuture, 
  bool onlyAvatar = false, 
  bool withName = false, 
  double size = Constants.defaultProfilePicRadius
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      CachedNetworkImage(
        imageUrl: user.picURL.isNotEmpty ? user.picURL : 'https://picsum.photos/id/237/200/300',
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            color: color,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: size,
            backgroundImage: imageProvider,
            backgroundColor: Colors.transparent,
          ),
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: size,
          backgroundColor: Colors.transparent,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: size,
          backgroundColor: Colors.transparent,
          child: Center(child: Icon(Icons.error)),
        ),
      ),
      Visibility(
        visible: !onlyAvatar || withName,
        child: SizedBox(width: Constants.mediumPadding)
      ),
      Visibility(
        visible: !onlyAvatar || withName,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Visibility(
              visible: withName,
              child: Text(user.name,
                style: TextStyle(
                  color: color,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.w600,
                  fontSize: Constants.defaultNameFontSize,
                ),
              ),
            ),
            Visibility(
              visible: !onlyAvatar,
              child: Text(user.username,
                style: TextStyle(
                  color: color.withOpacity(withName ? 0.6 : 1.0),
                  fontFamily: 'TribesRounded',
                  fontWeight: withName ? FontWeight.w500 : FontWeight.bold,
                  fontSize: withName ? 12 : Constants.defaultUsernameFontSize,
                ),
              ),
            ),
            Visibility(
              visible: addressFuture != null,
              child: FutureBuilder(
                future: addressFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var addresses = snapshot.data;
                    var first = addresses.first;
                    var location = '${first.addressLine}';
                    return Text(location,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontFamily: 'TribesRounded',
                        fontSize: 10,
                        fontWeight: FontWeight.normal
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Error getting address from coordinates: ${snapshot.error}');
                    return SizedBox.shrink();
                  } else {
                    return SizedBox.shrink();
                  }
                  
                }
              ),
            ),
            
            ],
        ),
      )
    ],
  );
}