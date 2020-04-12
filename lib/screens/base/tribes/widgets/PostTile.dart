import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/dialogs/FullscreenCarouselDialog.dart';
import 'package:tribes/screens/base/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomStrokedText.dart';
import 'package:tribes/shared/widgets/LikeButton.dart';
import 'package:tribes/shared/widgets/PostedDateTime.dart';
import 'package:tribes/shared/widgets/UserAvatar.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  final Function onEditPostPress;
  PostTile(this.post, this.tribeColor, this.onEditPostPress);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with TickerProviderStateMixin{

  Coordinates coordinates;
  Future<List<Address>> addressFuture;
  bool expanded = false;
  bool showLikedAnimation = false;

  // Liked animation
  AnimationController likedAnimationController;
  Animation likedAnimation;

  @override
  void initState() { 
    if((widget.post.lat != 0 && widget.post.lng != 0)) {
      coordinates = Coordinates(widget.post.lat, widget.post.lng);
      addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
    }

    likedAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    likedAnimation = Tween(begin: 20.0, end: 100.0).animate(CurvedAnimation(
      curve: Curves.bounceOut, parent: likedAnimationController)
    );

    likedAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() => showLikedAnimation = false);
        likedAnimationController.reset();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    likedAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PostTile()...');
    print('TribeTile: ${widget.post.id}');
    print('Current user ${currentUser.toString()}');

    bool isAuthor = currentUser.uid == widget.post.author;
    bool hasImages = widget.post.images.isNotEmpty;

    _postTileHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: StreamBuilder<UserData>(
              stream: DatabaseService().userData(widget.post.author),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return UserAvatar(
                    currentUserID: currentUser.uid, 
                    user: snapshot.data, 
                    color: widget.tribeColor, 
                    addressFuture: addressFuture,
                    strokeWidth: hasImages ? 2.0 : 0.0,
                    strokeColor: Colors.white,
                  );
                } else if(snapshot.hasError) {
                  print('Error retrieving author data: ${snapshot.error.toString()}');
                  return UserAvatarPlaceholder(child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)));
                } else {
                  return UserAvatarPlaceholder();
                }
              }
            ),
          ),
          IconButton(
            splashColor: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withAlpha(30),
            icon: CustomAwesomeIcon(icon: FontAwesomeIcons.pen, 
              color: isAuthor ? (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor) : Colors.transparent,
              size: Constants.smallIconSize,
              strokeWidth: isAuthor ? 4 : 0,
            ),
            onPressed: isAuthor ? () => widget.onEditPostPress(widget.post) : null,
          ),
        ],
      );
    }

    _postTileFooter() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                icon: CustomAwesomeIcon(
                  icon: FontAwesomeIcons.solidCommentDots, 
                  color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                  strokeWidth: 4,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: PostedDateTime(
              timestamp: widget.post.created, 
              color: hasImages ? Colors.white.withOpacity(0.8) : widget.tribeColor,
            ),
          ), 
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
                  CustomStrokedText(
                    text: '${widget.post.likes}',
                    textColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                    strokeColor: Colors.white,
                    minFontSize: 10,
                    fontWeight: FontWeight.bold,
                    strokeWidth: 4,
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
            children: <Widget>[

            // Images
            Visibility(
              visible: hasImages,
              child: GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => FullscreenCarouselDialog(images: widget.post.images, color: Colors.white)
                ), 
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.srcOver),
                  child: ImageCarousel(images: widget.post.images, color: widget.tribeColor),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.fromLTRB(8.0, 2.0, 0.0, 0.0),
                  child: _postTileHeader()
                ),
                
                // Title
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: CustomStrokedText(
                    text: widget.post.title,
                    textColor: hasImages ? Colors.white : Colors.black,
                    textAlign: TextAlign.start,
                    strokeColor: Colors.black87,
                    strokeWidth: hasImages ? 4.0 : 0.0,
                    letterSpacing: 1.0,
                    fontWeight: DynamicTheme.of(context).data.textTheme.title.fontWeight,
                    minFontSize: DynamicTheme.of(context).data.textTheme.title.fontSize,
                  ),
                ),

                // Content
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: GestureDetector(
                    onTap: () => setState(() => expanded = !expanded),
                    child: CustomStrokedText(
                      text:widget.post.content,
                      textColor: hasImages ? Colors.white : Colors.black,
                      textAlign: TextAlign.start,
                      strokeColor: Colors.black,
                      strokeWidth: hasImages ? 2.0 : 0.0,
                      maxLines: expanded ? null : Constants.postTileContentMaxLines,
                      overflow: TextOverflow.fade,
                      fontWeight: DynamicTheme.of(context).data.textTheme.body1.fontWeight,
                      minFontSize: DynamicTheme.of(context).data.textTheme.body1.fontSize,
                    ),
                  ),
                ),

                // Footer if Images is Empty
                Visibility(
                  visible: !hasImages,
                  child: _postTileFooter(),
                ),
              ]
            ),
            
            // Footer if Images is Not Empty
            Visibility(
              visible: hasImages,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _postTileFooter(),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: () {
        bool likedByUser = currentUser.likedPosts.contains(widget.post.id);
        if (!likedByUser) {
          print('User ${currentUser.uid} liked Post ${widget.post.id}');
          DatabaseService().likePost(currentUser.uid, widget.post.id);
          setState(() => showLikedAnimation = true);
          likedAnimationController.forward();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: DynamicTheme.of(context).data.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ]
        ),
        margin: EdgeInsets.fromLTRB(6.0, Constants.defaultPadding, 6.0, 4.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _postTileMain(),
              Visibility(
                visible: showLikedAnimation,
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: likedAnimationController,
                    builder: (context, child) => CustomAwesomeIcon(
                      icon: FontAwesomeIcons.solidHeart, 
                      size: likedAnimation.value, 
                      color: widget.tribeColor,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 4.0,
                          color: Colors.black87,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
