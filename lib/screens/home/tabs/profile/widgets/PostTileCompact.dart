import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/PostRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/Loading.dart';
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
            padding: EdgeInsets.only(top: 0.0),
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
          post.fileURL.isEmpty ? SizedBox.shrink() 
          : Container(
              padding: EdgeInsets.only(top: 4.0),
              child: CachedNetworkImage(
              imageUrl: post.fileURL,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.6),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(width: 1.0, color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.4),
                      blurRadius: 5,
                      offset: Offset(0, 0),
                    ),
                  ]
                ),
                height: Constants.postTileCompactImageHeight,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: Image(
                    image: imageProvider, 
                    fit: BoxFit.cover,
                    frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
                      return child;
                    },
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                height: Constants.postTileCompactImageHeight,
                width: MediaQuery.of(context).size.width,
                child: Loading(),
              ),
              errorWidget: (context, url, error) => Container(
                height: Constants.postTileCompactImageHeight,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Icon(Icons.error)),
              ),
              ),
          ),
        ],
      );
    }

    return InkWell(
        splashColor: Constants.tribesColor.withAlpha(30),
        onTap: () {
          Navigator.push(context, CustomPageTransition(
            type: CustomPageTransitionType.postDetails, 
            duration: Constants.pageTransition600, 
            child: StreamProvider<UserData>.value(
              value: DatabaseService().currentUser(currentUser.uid), 
              child: PostRoom(post, DynamicTheme.of(context).data.primaryColor),
            ),
          ));
        },
          child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: DynamicTheme.of(context).data.backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.6),
              blurRadius: 2,
              offset: Offset(0, 0),
            ),
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _postTileMain(),
          ],
        )
      ),
    );
  }
}
