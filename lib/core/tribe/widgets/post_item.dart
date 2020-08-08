import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:tribes/core/tribe/post_room_view.dart';
import 'package:tribes/core/tribe/widgets/image_carousel.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/like_button.dart';
import 'package:tribes/shared/widgets/posted_date_time.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  PostTile({
    @required this.post, 
    this.tribeColor = Constants.primaryColor, 
  });

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with TickerProviderStateMixin {

  Coordinates coordinates;
  Future<List<Address>> addressFuture;
  bool expanded = false;
  bool locationContainerExpanded = false;
  int currentImageIndex = 0;
  double cornerRadius = 20.0;
  bool showTextContent = false;

  // Liked animation
  AnimationController likedAnimationController;
  Animation likedAnimation;
  bool showLikedAnimation = false;

  @override
  void initState() { 
    if((widget.post.lat != 0 && widget.post.lng != 0)) {
      coordinates = Coordinates(widget.post.lat, widget.post.lng);
      addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
    }

    likedAnimationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 800));
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
    final UserData currentUser = locator<DatabaseService>().currentUserData;
    print('Building PostTile(${widget.post.id})...');

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
                    currentUserID: currentUser.id,
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
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: Colors.black26, width: 2.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12.0, 52.0, 12.0, 12.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
                children: [
                  // Title
                  Text(
                    widget.post.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: DynamicTheme.of(context).data.textTheme.headline6.copyWith(color: Colors.white),
                  ),

                  // Content
                  LayoutBuilder(builder: (context, size) {
                    // Build the textspan
                    var span = TextSpan(
                      text: widget.post.content,
                      style: DynamicTheme.of(context).data.textTheme.bodyText1.copyWith(color: Colors.white),
                    );

                    // Use a textpainter to determine if it will exceed max lines
                    var tp = TextPainter(
                      maxLines: 10,
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                      text: span,
                    );

                    // trigger it to layout
                    tp.layout(maxWidth: size.maxWidth);

                    // whether the text overflowed or not
                    var exceeded = tp.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text.rich(
                          span,
                          overflow: TextOverflow.fade,
                          maxLines: 10,
                        ),
                        SizedBox(height: Constants.defaultPadding),
                        Visibility(
                          visible: exceeded,
                          child: Text(
                            'See more',
                            style: DynamicTheme.of(context).data.textTheme.bodyText1.copyWith(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    );
                  }),
                ]
              ),
          ),
        ),
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
            color: widget.tribeColor.withOpacity(0.9),
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
                        var location = "${addressArr[0].trim()}" "${(locationContainerExpanded ? ', ${addressArr[1].trim()}, ${addresses.first.countryName}' : '')}";
                        return Text(
                          location,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TribesRounded'
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
      Timestamp timestamp = widget.post.created;
      
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: timestamp != null ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
          decoration: BoxDecoration(
            color: widget.tribeColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: timestamp != null ? PostedDateTime(
              vsync: this,
              alignment: Alignment.centerLeft,
              timestamp: DateTime.parse(timestamp.toDate().toString()), 
              color: Colors.white,
              fontSize: 10,
            ) : SizedBox.shrink(),
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

          // Left Side
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _buildDateAndTimeWidget(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: addressFuture != null ? 8.0 : 4.0, top: 4.0),
                child: Visibility(visible: addressFuture != null, child: _buildLocationWidget()),
              ),
            ],
          ),

          // Right Side
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: LikeButton(
                  currentUser: currentUser, 
                  postID: widget.post.id, 
                  color: Colors.white,
                  backgroundColor: widget.tribeColor.withOpacity(0.9),
                  fab: true,
                  mini: true,
                  withNumberOfLikes: true,
                  numberOfLikesPosition: LikeButtonTextPosition.LEFT,
                  onLiked: () {
                    setState(() => showLikedAnimation = true);
                    likedAnimationController.forward();
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 2.0, bottom: 4.0),
                child: FloatingActionButton(
                  heroTag: '${widget.post.id}-openTextFAB',
                  mini: true,
                  backgroundColor: widget.tribeColor.withOpacity(0.9),
                  onPressed: () => setState(() => showTextContent = !showTextContent),
                  child: CustomAwesomeIcon(
                    icon: showTextContent ? FontAwesomeIcons.envelopeOpenText : FontAwesomeIcons.solidEnvelope,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    _postImagesContent() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[

            // Images
            ImageCarousel(
              images: widget.post.images, 
              color: widget.tribeColor,
              onPageChange: (int index) => setState(() => currentImageIndex = index),
              initialIndex: currentImageIndex,
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
      );
    }

    _buildCard() {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cornerRadius),
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
      onTap: () => showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
          return PostRoomView(
            post: widget.post,
            tribeColor: widget.tribeColor, 
            initialImage: currentImageIndex,
            showTextContent: showTextContent,
          );
        },
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
              reverseCurve: Curves.easeOut
            ),
            child: child,
          );
        },
      ),
      onDoubleTap: () {
        bool likedByUser = currentUser.likedPosts.contains(widget.post.id);
        if (!likedByUser) {
          print('User ${currentUser.id} liked Post ${widget.post.id}');
          DatabaseService().likePost(currentUser.id, widget.post.id);
          setState(() => showLikedAnimation = true);
          likedAnimationController.forward();
        }
      },
      child: _buildCard()
    );
  }
}
