part of post_room_view;

class _PostRoomViewMobile extends ViewModelWidget<PostRoomViewModel> {
  @override
  Widget build(BuildContext context, PostRoomViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _showModalBottomSheet({Widget child}) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
        builder: (buildContext) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: child,
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
        elevation: 8.0,
      );
    }

    _buildDismissButton() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: FloatingActionButton(
              mini: true,
              child: CustomAwesomeIcon(
                icon: Platform.isIOS
                    ? FontAwesomeIcons.chevronLeft
                    : FontAwesomeIcons.arrowLeft,
                color: Colors.white,
              ),
              splashColor: Colors.transparent,
              backgroundColor: model.tribeColor.withOpacity(model.opacity),
              onPressed: model.onExitPress,
            ),
          ),
          AnimatedSize(
            vsync: model.vsync,
            alignment: Alignment.centerLeft,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            child: Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: StreamBuilder<MyUser>(
                  stream: model.authorData,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(
                          'Error retrieving author data: ${snapshot.error.toString()}');
                    }

                    return UserAvatar(
                      currentUserID: model.currentUserId,
                      user: snapshot.data,
                      color: model.tribeColor.withOpacity(model.opacity),
                      radius: 12,
                      strokeWidth: 2.0,
                      strokeColor: Colors.white,
                      padding: const EdgeInsets.all(6.0),
                      withDecoration: true,
                      textPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                      textColor: Colors.white,
                    );
                  }),
            ),
          ),
          IgnorePointer(
            ignoring: !model.isAuthor,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: model.isAuthor
                    ? model.tribeColor.withOpacity(0.8)
                    : Colors.transparent,
                elevation: model.isAuthor ? null : 0.0,
                onPressed: () => _showModalBottomSheet(
                  child: EditPostView(
                    post: model.post,
                    tribeColor: model.tribeColor,
                    onSave: model.onSavePost,
                    onDelete: () => Navigator.pop(context),
                  ),
                ),
                child: CustomAwesomeIcon(
                  icon: FontAwesomeIcons.pen,
                  color: model.isAuthor ? Colors.white : Colors.transparent,
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
          child: Theme(
            data: themeData.copyWith(highlightColor: Colors.white),
            child: Scrollbar(
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: ListView(
                    padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 64.0),
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                          height: model.isShowingOverlayWidgets
                              ? MediaQuery.of(context).padding.top
                              : 12.0),

                      // Title
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                            top: model.isShowingOverlayWidgets ? 52.0 : 0.0),
                        child: Text(
                          model.post.title,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: themeData.textTheme.headline6
                              .copyWith(color: Colors.white),
                        ),
                      ),

                      // Content
                      Text(
                        model.post.content,
                        maxLines: null,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        style: themeData.textTheme.bodyText1
                            .copyWith(color: Colors.white),
                      ),
                    ]),
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
          color: model.tribeColor.withOpacity(model.opacity),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: IgnorePointer(
            ignoring: !model.isShowingOverlayWidgets,
            child: AnimatedSize(
              vsync: model.vsync,
              alignment: Alignment.centerLeft,
              duration: model.overlayAnimDuration,
              curve: Curves.fastOutSlowIn,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                CustomAwesomeIcon(
                  icon: FontAwesomeIcons.mapMarkerAlt,
                  color: Colors.white,
                  size: 12,
                ),
                SizedBox(width: Constants.defaultPadding),
                FutureBuilder(
                    future: model.addressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var addresses = snapshot.data;
                        List<String> addressArr =
                            addresses.first.addressLine.split(",");
                        var location =
                            "${addressArr[0].trim()}, ${addressArr[1].trim()}, ${addresses.first.countryName}";
                        return Text(
                          location,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'TribesRounded'),
                        );
                      } else if (snapshot.hasError) {
                        print(
                            'Error getting address from coordinates: ${snapshot.error}');
                        return SizedBox.shrink();
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
              ]),
            ),
          ),
        ),
      );
    }

    _buildDateAndTimeWidget() {
      Timestamp timestamp = model.post.created;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: timestamp != null ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
          decoration: BoxDecoration(
            color: model.tribeColor.withOpacity(model.opacity),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: timestamp != null
                ? PostedDateTime(
                    vsync: model.vsync,
                    alignment: Alignment.centerLeft,
                    timestamp: DateTime.parse(timestamp.toDate().toString()),
                    color: Colors.white,
                    fontSize: 10,
                    fullscreen: true,
                  )
                : SizedBox.shrink(),
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
            ignoring: !model.isShowingOverlayWidgets,
            child: AnimatedOpacity(
              opacity: model.isShowingOverlayWidgets ? 1.0 : 0.0,
              duration: model.overlayAnimDuration,
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
                    padding: EdgeInsets.only(
                        left: 8.0,
                        bottom: model.addressFuture != null ? 8.0 : 4.0,
                        top: 4.0),
                    child: Visibility(
                        visible: model.addressFuture != null,
                        child: _buildLocationWidget()),
                  ),
                ],
              ),
            ),
          ),

          // Right Side
          IgnorePointer(
            ignoring: !model.isShowingOverlayWidgets,
            child: AnimatedOpacity(
              opacity: model.isShowingOverlayWidgets ? 1.0 : 0.0,
              duration: model.overlayAnimDuration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: LikeButton(
                      currentUser: model.currentUser,
                      postID: model.post.id,
                      color: Colors.white,
                      backgroundColor:
                          model.tribeColor.withOpacity(model.opacity),
                      fab: true,
                      mini: true,
                      withNumberOfLikes: true,
                      numberOfLikesPosition: LikeButtonTextPosition.LEFT,
                      onLiked: model.onLike,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor:
                          model.tribeColor.withOpacity(model.opacity),
                      onPressed: model.onShowTextContent,
                      child: CustomAwesomeIcon(
                        icon: model.isShowingTextContent
                            ? FontAwesomeIcons.envelopeOpenText
                            : FontAwesomeIcons.solidEnvelope,
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
        onTap: model.onBodyPress,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Images
                Positioned.fill(
                  child: FullscreenCarousel(
                    images: model.post.images,
                    color: model.tribeColor,
                    initialIndex: model.initialImage,
                    showOverlayWidgets: !model.isShowingTextContent &&
                        model.isShowingOverlayWidgets,
                    overlayAnimDuration: model.overlayAnimDuration,
                  ),
                ),

                // Title and Content
                Positioned.fill(
                  child: Visibility(
                    visible: model.isShowingTextContent,
                    child: _postTextContent(),
                  ),
                ),

                // Dismiss Button
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !model.isShowingOverlayWidgets,
                    child: AnimatedOpacity(
                      opacity: model.isShowingOverlayWidgets ? 1.0 : 0.0,
                      duration: model.overlayAnimDuration,
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
              visible: model.showLikedAnimation,
              child: AnimatedBuilder(
                animation: model.likedAnimationController,
                builder: (context, child) => CustomAwesomeIcon(
                  icon: FontAwesomeIcons.solidHeart,
                  size: model.likedAnimation.value,
                  color: Constants.likeHeartAnimationColor,
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

    return WillPopScope(
      onWillPop: model.onWillPop,
      child: FadeTransition(
        opacity: model.fadeInAnimation,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: _buildBody(),
        ),
      ),
    );
  }
}
