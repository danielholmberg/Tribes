import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/PostRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final Color tribeColor;
  final int index;
  PostTile({this.post, this.tribeColor, this.index});

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PostTile()...');
    print('TribeTile: ${post.id}');
    print('Current user ${currentUser.toString()}');

    _postTileHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<UserData>(
            stream: DatabaseService().userData(post.author),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return userAvatar(snapshot.data, color: tribeColor);
              } else if(snapshot.hasError) {
                print('Error retrieving author data: ${snapshot.error.toString()}');
                return SizedBox.shrink();
              } else {
                return SizedBox.shrink();
              }
            }
          ),
          index != null ? Text('#${index+1}', 
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: Constants.timestampFontSize,
            )
          ) : SizedBox.shrink(),
        ],
      );
    }

    _postTileFooter() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                splashColor: Colors.transparent,
                color: DynamicTheme.of(context).data.backgroundColor,
                icon: Icon(Icons.comment, 
                  color: (tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6)
                ),
                onPressed: () async {
                  Fluttertoast.showToast(
                    msg: 'Coming soon!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: postedDateTime(post.created)
          ),
          Spacer(),   
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('${post.likes}',
                    style: TextStyle(
                      color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                      fontFamily: 'TribesRounded',
                      fontSize: 10,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  likeButton(
                    currentUser, 
                    post.id, 
                    (tribeColor ?? DynamicTheme.of(context).data.primaryColor)
                  ),
                ],
              ),
            ],
          ),           
        ],
      );
    }

    _postTileMain() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
            child: _postTileHeader()
          ),
          Container(
            width: MediaQuery.of(context).size.width,            
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Hero(
              tag: 'postTitle-${post.id}',
              child: Text(post.title,
                  style: DynamicTheme.of(context).data.textTheme.title),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
            child: Hero(
              tag: 'postContent-${post.id}',
              child: Text(post.content,
                maxLines: Constants.postTileContentMaxLines,
                overflow: TextOverflow.fade,
                style: DynamicTheme.of(context).data.textTheme.body2),
            ),
          ),
          post.fileURL.isEmpty ? SizedBox.shrink() 
          : Container(
              padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
              child: Hero(
                tag: 'postImage-${post.id}',
                child: CachedNetworkImage(
                imageUrl: post.fileURL,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    color: (tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(width: 2.0, color: (tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: (tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ]
                  ),
                  height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
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
                  height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
                  width: MediaQuery.of(context).size.width,
                  child: Loading(),
                ),
                errorWidget: (context, url, error) => Container(
                  height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Icon(Icons.error)),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: (tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.2)), 
              ),
            ),
            child: _postTileFooter()
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: DynamicTheme.of(context).data.backgroundColor,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: tribeColor.withOpacity(0.5) ?? DynamicTheme.of(context).data.accentColor,
            blurRadius: 2,
            offset: Offset(0, 0),
          ),
        ]
      ),
      margin: EdgeInsets.fromLTRB(0.0, Constants.largePadding, 0.0, 0.0),
      child: InkWell(
        splashColor: Constants.tribesColor.withAlpha(30),
        onTap: () {
          Navigator.push(context, CustomPageTransition(
            type: CustomPageTransitionType.postDetails, 
            duration: Constants.pageTransition600, 
            child: StreamProvider<UserData>.value(
              value: DatabaseService().currentUser(currentUser.uid), 
              child: PostRoom(
                tribeColor: tribeColor, 
                post: post, 
                index: index,
              ),
            ),
          ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              _postTileMain(),
            ],
          ),
        ),
      ),
    );
  }
}
