part of profile_view;

class _ProfileViewMobile extends StatelessWidget {
  final ProfileViewModel viewModel;
  _ProfileViewMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    _profileHeader() {
      return Container(
        padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                GestureDetector(
                  onTap: () => viewModel.isAnotherUser ? null : (viewModel.isBusy ? null : viewModel.chooseNewProfilePic()),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: themeData.backgroundColor, width: 2.0),
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Platform.isAndroid
                          ? FutureBuilder<void>(
                            future: viewModel.retrieveLostData(),
                            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                              // TODO:
                              /* switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return _imageFile != null ? _profilePicture() : _placeholderPic();
                                case ConnectionState.done:
                                  return _profilePicture();
                                default:
                                  if(snapshot.hasError) print(snapshot.error.toString());
                                  return _profilePicture();
                              } */
                              return viewModel.profilePicture();
                            },
                          ) : viewModel.profilePicture(),
                      ),
                      
                      viewModel.isAnotherUser ? SizedBox.shrink() 
                      : Positioned(
                        bottom: 2, 
                        right: 2, 
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Constants.buttonIconColor, width: 2.0),
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(Constants.maxCornerRadius),
                            child: Padding(
                              padding:EdgeInsets.all(4.0),
                              child: CustomAwesomeIcon(
                                icon: FontAwesomeIcons.plus,
                                size: 12.0,
                              )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      NumberFormat.compact().format(viewModel.isAnotherUser ? viewModel.otherUser.createdPosts.length : viewModel.currentUser.createdPosts.length), 
                      style: TextStyle(
                        color: Colors.white, 
                        fontFamily: 'TribesRounded', 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Published', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      NumberFormat.compact().format(viewModel.isAnotherUser ? viewModel.otherUser.likedPosts.length : viewModel.currentUser.likedPosts.length), 
                      style: TextStyle(
                        color: Colors.white, 
                        fontFamily: 'TribesRounded', 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Liked', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                  ],
                ),
                Spacer(),
                StreamBuilder<List<Tribe>>(
                  stream: DatabaseService().joinedTribes(viewModel.isAnotherUser ? viewModel.otherUser.id : viewModel.currentUser.id),
                  builder: (context, snapshot) {
                    List<Tribe> tribesList =
                        snapshot.hasData ? snapshot.data : [];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          NumberFormat.compact().format(tribesList.length), 
                          style: TextStyle(
                            color: Colors.white, 
                            fontFamily: 'TribesRounded', 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Tribes', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                      ],
                    );
                  }
                ),
                Spacer(),
              ],
            )
          ],
        ),
      );
    }

    _profileInfo() {
      return Card(
        margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        elevation: 0.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(viewModel.isAnotherUser ? viewModel.otherUser.name : viewModel.currentUser.name,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontFamily: 'TribesRounded',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: Constants.defaultPadding),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.at, 
                        color: themeData.primaryColor.withOpacity(0.7),
                        size: Constants.tinyIconSize,
                      ),
                      SizedBox(width: Constants.defaultPadding),
                      Text(viewModel.isAnotherUser ? viewModel.otherUser.email : viewModel.currentUser.email,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontFamily: 'TribesRounded',
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(height: Constants.defaultPadding),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Platform.isIOS ? FontAwesomeIcons.locationArrow : FontAwesomeIcons.mapMarkerAlt, 
                        color: themeData.primaryColor.withOpacity(0.7),
                        size: Constants.tinyIconSize,
                      ),
                      SizedBox(width: Constants.defaultPadding),
                      FutureBuilder(
                        future: viewModel.addressFuture,
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
                    ],
                  )
                ],
              ),
              Visibility(
                visible: viewModel.isAnotherUser ? viewModel.otherUser.info.isNotEmpty : viewModel.currentUser.info.isNotEmpty,
                child: Divider(),
              ),
              Visibility(
                visible: viewModel.isAnotherUser ? viewModel.otherUser.info.isNotEmpty : viewModel.currentUser.info.isNotEmpty,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: AutoSizeText(viewModel.isAnotherUser ? viewModel.otherUser.info : viewModel.currentUser.info,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    minFontSize: 12,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.normal
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: themeData.primaryColor,
      body: SafeArea(
        bottom: false,
          child: Container(
          child: !viewModel.dataReady ? Center(child: Loading(color: Constants.accentColor)) : DefaultTabController(
            length: viewModel.tabController.length,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: viewModel.isAnotherUser ? (viewModel.otherUser.info.isNotEmpty ? 330 : 280): (viewModel.currentUser.info.isNotEmpty ? 330 : 280),
                    floating: false,
                    pinned: false,
                    elevation: 4.0,
                    backgroundColor: themeData.primaryColor,
                    leading: !viewModel.isAnotherUser ? SizedBox.shrink() 
                    : GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: CustomAwesomeIcon(
                        icon: FontAwesomeIcons.times, 
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 16, top: 12),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(viewModel.isAnotherUser ? viewModel.otherUser.username : viewModel.currentUser.username,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        )
                                      ),
                                    ],
                                  ),

                                  viewModel.isAnotherUser ? SizedBox.shrink() 
                                  : Positioned(right: 0, 
                                    child: IconButton(
                                      color: themeData.buttonColor,
                                      icon: Icon(FontAwesomeIcons.cog, color: Constants.buttonIconColor),
                                      splashColor: Colors.transparent,
                                      onPressed: viewModel.isAnotherUser ? null : () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => ProfileSettingsDialog(user: viewModel.currentUser),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              _profileHeader(),
                              SizedBox(height: Constants.defaultPadding),
                              _profileInfo(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      color: themeData.primaryColor,
                      child: TabBar(
                        labelColor: Constants.buttonIconColor,
                        indicatorColor: Constants.buttonIconColor,
                        unselectedLabelColor: Constants.buttonIconColor.withOpacity(0.7),
                        tabs: [
                          Tab(icon: Icon(Icons.dashboard)),
                          Tab(icon: Icon(FontAwesomeIcons.solidHeart)),
                          Tab(icon: Icon(FontAwesomeIcons.home))
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          CreatedPosts(user: viewModel.otherUser ?? viewModel.currentUser, viewOnly: viewModel.isAnotherUser),
                          LikedPosts(user: viewModel.otherUser ?? viewModel.currentUser, viewOnly: viewModel.isAnotherUser),
                          JoinedTribes(user: viewModel.otherUser ?? viewModel.currentUser, showSecrets: !viewModel.isAnotherUser),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}