import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/screens/EditPost.dart';
import 'package:tribes/screens/base/tribes/widgets/FullscreenCarousel.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/LikeButton.dart';
import 'package:tribes/shared/widgets/PostedDateTime.dart';
import 'dart:ui' as ui;

import 'package:tribes/shared/widgets/UserAvatar.dart';

class PostRoom extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  final int initialImage;
  final bool showTextContent;
  final Function onEditPostPress;
  PostRoom({
    @required this.post,
    this.tribeColor = Constants.primaryColor,
    this.initialImage = 0,
    this.showTextContent = false,
    this.onEditPostPress,
  });

  @override
  _PostRoomState createState() => _PostRoomState();
}

class _PostRoomState extends State<PostRoom> with TickerProviderStateMixin {

  Coordinates coordinates;
  Future<List<Address>> addressFuture;

  bool showTextContent = false;
  bool isShowingOverlayWidgets = true;
  Post post;
  double opacity = 0.9;

  // Fade-in animation
  AnimationController fadeInController;
  Animation<double> fadeInAnimation;

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

    fadeInController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    fadeInAnimation = CurvedAnimation(parent: fadeInController, curve: Curves.easeIn);

    fadeInController.addListener(() {
      if(this.mounted) setState(() {});
    });

    fadeInController.forward();

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

    showTextContent = widget.showTextContent;
    post = widget.post;

    super.initState();
  }

  @override
  void dispose() {
    fadeInController.dispose();
    likedAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PostRoom()...');
    print('TribeTile: ${widget.post.id}');
    print('Current user ${currentUser.toString()}');
    
    bool isAuthor = currentUser.uid == post.author;

    _showModalBottomSheet({Widget child}) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (buildContext) {
          return StreamProvider<UserData>.value(
            value: DatabaseService().currentUser(currentUser.uid), 
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: child,
              ),
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 8.0
      );
    }

    _buildDismissButton() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget> [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: FloatingActionButton(
              mini: true,
              child: CustomAwesomeIcon(
                icon: Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft,
                color: Colors.white,
              ),
              splashColor: Colors.transparent,
              backgroundColor: widget.tribeColor.withOpacity(opacity),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          AnimatedSize(
            vsync: this,
            alignment: Alignment.centerLeft,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            child: Container(
              margin: const EdgeInsets.only(top: 4.0),
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
                    textPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                    textColor: Colors.white,
                  );
                }
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !isAuthor,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: isAuthor ? widget.tribeColor.withOpacity(0.8) : Colors.transparent,
                elevation: isAuthor ? null : 0.0,
                onPressed: () => _showModalBottomSheet(
                  child: EditPost(
                    post: post, 
                    tribeColor: widget.tribeColor, 
                    onSave: (Post updatedPost) => setState(() => post = updatedPost),
                    onDelete: () => Navigator.pop(context),
                  ),
                ),
                child: CustomAwesomeIcon(
                  icon: FontAwesomeIcons.pen,
                  color: isAuthor ? Colors.white : Colors.transparent,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      );
    }

    _postTextContent() {
      return Container(
        color: Colors.black.withOpacity(0.4),
        child: BackdropFilter(
          filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            child: Theme(
              data: DynamicTheme.of(context).data.copyWith(highlightColor: Colors.white),
              child: Scrollbar(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12.0, 52.0, 12.0, 64.0),
                  shrinkWrap: true,
                  children: [
                    // Title
                    Text(
                      post.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: DynamicTheme.of(context).data.textTheme.title.copyWith(color: Colors.white),
                    ),

                    // Content
                    Text(
                      post.content,
                      maxLines: null,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: DynamicTheme.of(context).data.textTheme.body2.copyWith(color: Colors.white),
                    ),
                  ]
                ),
              ),
            ),
          ),
        ),
      );
    }

    _buildLocationWidget() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        decoration: BoxDecoration(
          color: widget.tribeColor.withOpacity(opacity),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: IgnorePointer(
            ignoring: !isShowingOverlayWidgets,
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
                        var location = "${addressArr[0].trim()}, ${addressArr[1].trim()}, ${addresses.first.countryName}";
                        return Text(
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
          color: widget.tribeColor.withOpacity(opacity),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: PostedDateTime(
            vsync: this,
            alignment: Alignment.centerLeft,
            timestamp: post.created, 
            color: Colors.white,
            fontSize: 10,
            fullscreen: true,
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
          IgnorePointer(
            ignoring: !isShowingOverlayWidgets,
            child: AnimatedOpacity(
              opacity: isShowingOverlayWidgets ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildDateAndTimeWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 4.0),
                    child: Visibility(visible: addressFuture != null, child: _buildLocationWidget()),
                  ),
                ],
              ),
            ),
          ),

          // Right Side
          IgnorePointer(
            ignoring: !isShowingOverlayWidgets,
            child: AnimatedOpacity(
              opacity: isShowingOverlayWidgets ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: LikeButton(
                      user: currentUser, 
                      postID: widget.post.id, 
                      color: Colors.white,
                      backgroundColor: widget.tribeColor.withOpacity(opacity),
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
                    padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: widget.tribeColor.withOpacity(opacity),
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
            ),
          ),
        ],
      );
    }

    _buildBody() {
      return GestureDetector(
        onTap: () {
          if(isShowingOverlayWidgets) {
            setState(() => isShowingOverlayWidgets = false);
          } else {
            setState(() => isShowingOverlayWidgets = true);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[

                // Images
                Positioned.fill(child: 
                  FullscreenCarousel(
                    images: post.images,
                    color: widget.tribeColor,
                    initialIndex: widget.initialImage,
                    showOverlayWidgets: isShowingOverlayWidgets,
                  ),
                ),

                // Title and Content
                Positioned.fill(
                  child: Visibility(
                    visible: showTextContent, 
                    child: _postTextContent(),
                  ),
                ),

                // Dismiss Button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !isShowingOverlayWidgets,
                    child: AnimatedOpacity(
                      opacity: isShowingOverlayWidgets ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: _buildDismissButton(),
                    ),
                  ),
                ),

                // Details
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _postDetailsRow(),
                ),
                
              ],
            ),
            Visibility(
              visible: showLikedAnimation,
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
            )
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: fadeInAnimation,
      child: Container(
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }
}