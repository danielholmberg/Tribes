part of map_view;

class _MapViewMobile extends ViewModelWidget<MapViewModel> {
  @override
  Widget build(BuildContext context, MapViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _buildMap(List<String> friendsList, Set<Marker> markers) {
      return model.showMap
          ? AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: model.isMapLoading ? 0.0 : 1.0,
              child: GoogleMap(
                padding: EdgeInsets.only(
                  left: 12,
                  bottom: kBottomNavigationBarHeight + 92,
                ),
                onMapCreated: model.onMapCreated,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: model.initialPosition,
                  zoom: 5.0,
                ),
                markers: markers,
              ),
            )
          : Center(child: Loading());
    }

    _buildUserAvatarsList(
      List<String> friendsList,
      List<MyUser> friendsDataList,
    ) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Container(
          height: 92,
          child: Row(
            children: <Widget>[
              Expanded(
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(6.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          return await model.mapController.future.then(
                            (controller) => controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    friendsDataList[index].lat,
                                    friendsDataList[index].lng,
                                  ),
                                  zoom: 15.0,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              child: UserAvatar(
                                currentUserID: model.currentUser.id,
                                user: friendsDataList[index],
                                radius: 30,
                                shadow: BoxShadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2.0,
                                  color: Colors.black54,
                                ),
                                nameFontSize: 24,
                                strokeWidth: 2.0,
                                color: Colors.black54,
                                strokeColor: Colors.black54,
                                direction: UserAvatarDirections.vertical,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: StreamBuilder<List<Tribe>>(
            stream: model.joinedTribes,
            builder: (context, snapshot) {
              List<Tribe> tribesList = snapshot.hasData ? snapshot.data : [];

              // TO-DO: Change to only listen to a stream of relevant users instead of ALL users.
              return StreamBuilder<List<MyUser>>(
                stream: model.allUsers,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<MyUser> usersList = snapshot.data;
                    List<String> friendsList = [];
                    List<MyUser> friendsDataList = [];
                    Set<Marker> markers = Set<Marker>();

                    tribesList.forEach((tribe) => friendsList.addAll(tribe
                        .members
                        .where((memberID) => (!friendsList.contains(memberID) &&
                            model.currentUser.id != memberID))));

                    friendsList.forEach((friendID) => friendsDataList.add(
                        usersList.singleWhere((user) => user.id == friendID)));
                    friendsDataList.forEach(
                      (friendData) => markers.add(
                        Marker(
                          markerId: MarkerId(friendData.id),
                          position: LatLng(friendData.lat, friendData.lng),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            Constants.primaryColorHueValue,
                          ),
                          infoWindow: InfoWindow(
                            title: friendData.username,
                            snippet: friendData.name,
                          ),
                        ),
                      ),
                    );

                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        // Google Map Stack Widget
                        _buildMap(friendsList, markers),

                        // Users List Widget
                        _buildUserAvatarsList(friendsList, friendsDataList),

                        // Map Loading indicator
                        Opacity(
                            opacity: model.isMapLoading ? 1.0 : 0.0,
                            child: Center(child: Loading()))
                      ],
                    );
                  } else if (snapshot.hasError) {
                    print(
                        'Error retrieving users for Map: ${snapshot.error.toString()}');
                    return Center(child: Text('Unable to retrieve users'));
                  } else {
                    return Center(child: Loading());
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
