import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/PostRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  PostTile(this.post, this.tribeColor);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {

  Coordinates coordinates;
  Future<List<Address>> addressFuture;
  bool expanded = false;

  @override
  void initState() { 
    if((widget.post.lat != 0 && widget.post.lng != 0)) {
      coordinates = Coordinates(widget.post.lat, widget.post.lng);
      addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PostTile()...');
    print('TribeTile: ${widget.post.id}');
    print('Current user ${currentUser.toString()}');

    bool isAuthor = currentUser.uid == widget.post.author;

    _postTileHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<UserData>(
            stream: DatabaseService().userData(widget.post.author),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return userAvatar(user: snapshot.data, color: widget.tribeColor, addressFuture: addressFuture);
              } else if(snapshot.hasError) {
                print('Error retrieving author data: ${snapshot.error.toString()}');
                return SizedBox.shrink();
              } else {
                return SizedBox.shrink();
              }
            }
          ),
          isAuthor ? IconButton(
            splashColor: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withAlpha(30),
            icon: Icon(Icons.edit, 
              color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
            ),
            iconSize: 20,
            onPressed: () async {
              Navigator.push(context, CustomPageTransition(
                type: CustomPageTransitionType.postDetails, 
                  duration: Constants.pageTransition600, 
                  child: StreamProvider<UserData>.value(
                    value: DatabaseService().currentUser(currentUser.uid), 
                    child: PostRoom(widget.post, widget.tribeColor),
                  ),
                )
              );
            },
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
                  color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6)
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
            child: postedDateTime(widget.post.created, color: widget.tribeColor)
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
                  Text('${widget.post.likes}',
                    style: TextStyle(
                      color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                      fontFamily: 'TribesRounded',
                      fontSize: 10,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  likeButton(
                    currentUser, 
                    widget.post.id, 
                    (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)
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
            padding: EdgeInsets.fromLTRB(8.0, isAuthor ? 4.0 : 10.0, 0.0, isAuthor ? 0.0 : 4.0),
            child: _postTileHeader()
          ),
          Container(
            width: MediaQuery.of(context).size.width,            
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(widget.post.title,
                style: DynamicTheme.of(context).data.textTheme.title),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
            child: Text(widget.post.content,
              maxLines: expanded ? null : Constants.postTileContentMaxLines,
              overflow: TextOverflow.fade,
              style: DynamicTheme.of(context).data.textTheme.body2),
          ),
          widget.post.fileURL.isEmpty ? SizedBox.shrink() 
          : Container(
              padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
              child: CachedNetworkImage(
              imageUrl: widget.post.fileURL,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(width: 2.0, color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4),
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
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.2)), 
              ),
            ),
            child: _postTileFooter()
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: DynamicTheme.of(context).data.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          //border: Border.all(color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black54, //(widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ]
        ),
        margin: EdgeInsets.fromLTRB(6.0, Constants.defaultPadding, 6.0, 4.0),
        child: InkWell(
          splashColor: Constants.tribesColor.withAlpha(30),
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
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
      ),
    );
  }
}
