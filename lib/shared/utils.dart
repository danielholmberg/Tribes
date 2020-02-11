import 'package:cached_network_image/cached_network_image.dart';
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

Widget userAvatar(UserData user, {Color color: Constants.primaryColor, Future addressFuture}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      CachedNetworkImage(
        imageUrl: user.picURL.isNotEmpty ? user.picURL : 'https://picsum.photos/id/237/200/300',
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: Constants.defaultProfilePicRadius,
          backgroundImage: imageProvider,
          backgroundColor: Colors.transparent,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: Constants.defaultProfilePicRadius,
          backgroundColor: Colors.transparent,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: Constants.defaultProfilePicRadius,
          backgroundColor: Colors.transparent,
          child: Center(child: Icon(Icons.error)),
        ),
      ),
      SizedBox(width: Constants.mediumPadding),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(user.username,
            style: TextStyle(
              color: color,
              fontFamily: 'TribesRounded',
              fontWeight: FontWeight.bold,
              fontSize: Constants.defaultUsernameFontSize,
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
      )
    ],
  );
}