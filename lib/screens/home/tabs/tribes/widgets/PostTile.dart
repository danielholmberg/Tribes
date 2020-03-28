import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/dialogs/FullscreenCarouselDialog.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/EditPost.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/LikeButton.dart';
import 'package:tribes/shared/widgets/PostedDateTime.dart';
import 'package:tribes/shared/widgets/UserAvatar.dart';

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
                return UserAvatar(user: snapshot.data, color: widget.tribeColor, addressFuture: addressFuture);
              } else if(snapshot.hasError) {
                print('Error retrieving author data: ${snapshot.error.toString()}');
                return UserAvatarPlaceholder(child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)));
              } else {
                return UserAvatarPlaceholder();
              }
            }
          ),
          isAuthor ? IconButton(
            splashColor: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withAlpha(30),
            icon: CustomAwesomeIcon(icon: FontAwesomeIcons.pen, 
              color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
              size: Constants.smallIconSize,
            ),
            onPressed: () async {
              Navigator.push(context, CustomPageTransition(
                type: CustomPageTransitionType.postDetails, 
                  duration: Constants.pageTransition600, 
                  child: StreamProvider<UserData>.value(
                    value: DatabaseService().currentUser(currentUser.uid), 
                    child: EditPost(widget.post, widget.tribeColor),
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
                icon: CustomAwesomeIcon(icon: FontAwesomeIcons.solidCommentDots, 
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
            child: PostedDateTime(timestamp: widget.post.created, color: widget.tribeColor)
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
                  LikeButton(
                    user: currentUser, 
                    postID: widget.post.id, 
                    color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)
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

          // Header
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(8.0, isAuthor ? 2.0 : 8.0, 0.0, 0.0),
            child: _postTileHeader()
          ),

          // Title
          Container(
            width: MediaQuery.of(context).size.width,            
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(widget.post.title,
                style: DynamicTheme.of(context).data.textTheme.title),
          ),

          // Content
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(widget.post.content,
              maxLines: expanded ? null : Constants.postTileContentMaxLines,
              overflow: TextOverflow.fade,
              style: DynamicTheme.of(context).data.textTheme.body2),
          ),

          SizedBox(height: widget.post.images.isEmpty ? 0.0 : 8.0),

          // ImageCarousel
          widget.post.images.isEmpty 
          ? SizedBox.shrink() 
          : GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) => FullscreenCarouselDialog(images: widget.post.images, color: Colors.white)
            ), 
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.2)),
                  bottom: BorderSide(color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.2)), 
                ),
              ),
              child: ImageCarousel(images: widget.post.images, color: widget.tribeColor)
            ),
          ),

          // Footer
          Container(
            child: _postTileFooter(),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: DynamicTheme.of(context).data.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.tribeColor.withOpacity(0.4), width: 2),
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
    );
  }
}
