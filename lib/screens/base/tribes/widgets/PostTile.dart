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
import 'package:tribes/shared/widgets/LikeButton.dart';
import 'package:tribes/shared/widgets/PostedDateTime.dart';
import 'package:tribes/shared/widgets/UserAvatar.dart';
import 'dart:ui' as ui;

class PostTile extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  final Function onEditPostPress;
  PostTile({
    @required this.post, 
    this.tribeColor = Constants.primaryColor, 
    this.onEditPostPress
  });

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with TickerProviderStateMixin{

  Coordinates coordinates;
  Future<List<Address>> addressFuture;
  bool expanded = false;
  bool showLikedAnimation = false;
  bool locationContainerExpanded = false;
  int currentImageIndex = 0;
  double cornerRadius = 20.0;
  bool showTextContent = false;

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

    _postHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedSize(
            vsync: this,
            alignment: Alignment.centerLeft,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            child: Container(
              margin: const EdgeInsets.only(top: 8.0, left: 6.0),
              child: StreamBuilder<UserData>(
                stream: DatabaseService().userData(widget.post.author),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    print('Error retrieving author data: ${snapshot.error.toString()}');
                  } 
                  
                  return UserAvatar(
                    currentUserID: currentUser.uid, 
                    user: snapshot.data, 
                    color: widget.tribeColor,
                    radius: 12,
                    strokeWidth: 2.0,
                    strokeColor: Colors.white,
                    padding: const EdgeInsets.all(6.0),
                    withDecoration: true,
                    textPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                    textColor: Colors.white,
                  );
                }
              ),
            ),
          ),
        ],
      );
    }

    _postTextContent() {
      return Container(
        color: Colors.black.withOpacity(0.4),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(cornerRadius),
            topRight: Radius.circular(cornerRadius)
          ),
          child: BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12.0, 52.0, 12.0, 52.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.post.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: DynamicTheme.of(context).data.textTheme.title.copyWith(color: Colors.white),
                  ),

                  // Content
                  Expanded(
                    child: Theme(
                      data: DynamicTheme.of(context).data.copyWith(highlightColor: Colors.white),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.post.content,
                            maxLines: null,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            style: DynamicTheme.of(context).data.textTheme.body2.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ),
        ),
      );
    }

    _postFooter({Color color}) {
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
                icon: CustomAwesomeIcon(icon: FontAwesomeIcons.solidCommentDots, 
                  color: color ?? widget.tribeColor.withOpacity(0.6)
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
                  Text(
                    '${widget.post.likes}',
                    style: TextStyle(
                      color: color ?? widget.tribeColor,
                      fontFamily: 'TribesRounded',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LikeButton(
                    user: currentUser, 
                    postID: widget.post.id, 
                    color: color ?? widget.tribeColor,
                  ),
                ],
              ),
            ],
          ),           
        ],
      );
    }

    _buildLocationWidget() {
      return GestureDetector(
        onTap: () { 
          if(locationContainerExpanded) {
            setState(() {
              locationContainerExpanded = false;
            });
          } else {
            setState(() {
              locationContainerExpanded = true;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
          decoration: BoxDecoration(
            color: widget.tribeColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: AnimatedSize(
              vsync: this,
              alignment: Alignment.centerLeft,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomAwesomeIcon(icon: FontAwesomeIcons.mapMarkerAlt, color: Colors.white, size: 12,),
                  SizedBox(width: Constants.defaultPadding),
                  FutureBuilder(
                    future: addressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var addresses = snapshot.data;
                        List<String> addressArr = addresses.first.addressLine.split(",");
                        var location = "${addressArr[0].trim()}" "${(locationContainerExpanded ? '\n${addressArr[1].trim()}, ${addresses.first.countryName}' : '')}";
                        return Padding(
                          padding: EdgeInsets.only(right: locationContainerExpanded ? 4.0 : 0.0),
                          child: Text(
                            location,
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'TribesRounded'
                            ),
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
                ]
              ),
            ),
          ),
        ),
      );
    }

    _buildDateAndTimeWidget() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        decoration: BoxDecoration(
          color: widget.tribeColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: PostedDateTime(
            vsync: this,
            alignment: Alignment.centerRight,
            timestamp: widget.post.created, 
            color: Colors.white,
            fontSize: 10,
            expandedHorizontalPadding: 4.0,
          ),
        ),
      );
    }

    _postDetailsRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 6.0, bottom: 8.0),
            child: ConstrainedBox(
              constraints: (BoxConstraints(maxWidth: MediaQuery.of(context).size.width/2)),
              child: Visibility(visible: addressFuture != null, child: _buildLocationWidget()),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                visible: isAuthor,
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: widget.tribeColor.withOpacity(0.8),
                    onPressed: () => widget.onEditPostPress(widget.post),
                    child: CustomAwesomeIcon(
                      icon: FontAwesomeIcons.pen,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: widget.tribeColor.withOpacity(0.8),
                  onPressed: () => setState(() => showTextContent = !showTextContent),
                  child: CustomAwesomeIcon(
                    icon: showTextContent ? FontAwesomeIcons.envelopeOpenText : FontAwesomeIcons.solidEnvelope,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6.0, bottom: 8.0, top: 4.0),
                child: ConstrainedBox(
                  constraints: (BoxConstraints(maxWidth: MediaQuery.of(context).size.width/3)),
                  child: _buildDateAndTimeWidget(),
                ),
              ),
            ],
          ),
        ],
      );
    }

    _postImagesContent() {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius)
        ),
        child: Column(
          children: <Widget>[

            // Images
            Stack(
              alignment: Alignment.center,
              children: <Widget>[

                // Images
                GestureDetector(
                  onTap: showTextContent ? null : () => showDialog(
                    context: context,
                    builder: (context) => FullscreenCarouselDialog(
                      images: widget.post.images, 
                      color: widget.tribeColor, 
                      initialIndex: currentImageIndex,
                      onPageChange: (int index) => setState(() => currentImageIndex = index),
                    ),
                  ),
                  child: ImageCarousel(
                    images: widget.post.images, 
                    color: widget.tribeColor,
                    onPageChange: (int index) => setState(() => currentImageIndex = index),
                    initialIndex: currentImageIndex,
                  ),
                ),

                // Title and Content
                Positioned.fill(
                  child: Visibility(
                    visible: showTextContent, 
                    child: _postTextContent(),
                  ),
                ),

                // Header
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: _postHeader(),
                ),

                // Details
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: _postDetailsRow(),
                ),
              ],
            ),
            
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.0, color: Colors.black12),
                ),
              ),
              child: _postFooter(color: DynamicTheme.of(context).data.primaryColor),
            ),
          ],
        ),
      );
    }

    _buildCard() {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ]
        ),
        margin: EdgeInsets.fromLTRB(6.0, Constants.defaultPadding, 6.0, 4.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _postImagesContent(),
            Visibility(
              visible: false, 
              child: _postTextContent(),
            ),
            Visibility(
              visible: showLikedAnimation,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: likedAnimationController,
                  builder: (context, child) => CustomAwesomeIcon(
                    icon: FontAwesomeIcons.solidHeart, 
                    size: likedAnimation.value, 
                    color: DynamicTheme.of(context).data.primaryColor,
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
      child: _buildCard()
    );
  }
}
