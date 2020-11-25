import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

// ToDo - Change to Stateless widget and move all state and business-logic to related [viewName]_view_model.dart file.

class MapView extends StatefulWidget {
  static const routeName = '/map';

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin {
  // Old Town @ Stockholm,Sweden
  LatLng _initialPosition = LatLng(Constants.initialLat, Constants.initialLng);

  Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  bool _isMapLoading = true;
  bool _showMap = false;

  StreamSubscription<Position> positionStream;

  @override
  void initState() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ).listen((Position position) async {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      if (position != null) {
        await DatabaseService()
            .updateUserLocation(position.latitude, position.longitude);
      }
    });

    // Wait to initialize Google Map until Widget-tree has had the time to initialize.
    /* Future.delayed(Duration(milliseconds: 300), () { 
      if(this.mounted) {
        setState(() => _showMap = true);
      }
    }); */

    if (this.mounted) {
      setState(() => _showMap = true);
    }

    super.initState();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentUser = locator<DatabaseService>().currentUserData;
    print('Building Map()...');

    ThemeData themeData = Theme.of(context);

    _buildMap(List<String> friendsList, Set<Marker> markers) {
      return _showMap
          ? AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isMapLoading ? 0.0 : 1.0,
              child: GoogleMap(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                onMapCreated: _onMapCreated,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 5.0,
                ),
                markers: markers,
              ),
            )
          : Center(child: Loading());
    }

    _buildUserAvatarsList(
        List<String> friendsList, List<MyUser> friendsDataList) {
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
                          onTap: () async => await mapController.future.then(
                              (controller) => controller.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                      target: LatLng(friendsDataList[index].lat,
                                          friendsDataList[index].lng),
                                      zoom: 15.0)))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: UserAvatar(
                                  currentUserID: currentUser.id,
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
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      child: currentUser == null
          ? Loading()
          : Scaffold(
              resizeToAvoidBottomInset: false,
              body: StreamBuilder<List<Tribe>>(
                  stream: DatabaseService().joinedTribes(currentUser.id),
                  builder: (context, snapshot) {
                    List<Tribe> tribesList =
                        snapshot.hasData ? snapshot.data : [];

                    // TO-DO: Change to only listen to a stream of relevant users instead of ALL users.
                    return StreamBuilder<List<MyUser>>(
                        stream: DatabaseService().users,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<MyUser> usersList = snapshot.data;
                            List<String> friendsList = [];
                            List<MyUser> friendsDataList = [];
                            Set<Marker> markers = Set<Marker>();

                            tribesList.forEach((tribe) => friendsList.addAll(
                                tribe.members.where((memberID) =>
                                    (!friendsList.contains(memberID) &&
                                        currentUser.id != memberID))));

                            friendsList.forEach((friendID) =>
                                friendsDataList.add(usersList.singleWhere(
                                    (user) => user.id == friendID)));
                            friendsDataList.forEach((friendData) =>
                                markers.add(Marker(
                                  markerId: MarkerId(friendData.id),
                                  position:
                                      LatLng(friendData.lat, friendData.lng),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                      Constants.primaryColorHueValue),
                                  infoWindow: InfoWindow(
                                      title: friendData.username,
                                      snippet: friendData.name),
                                )));

                            return Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                // Google Map Stack Widget
                                _buildMap(friendsList, markers),

                                // Statusbar background
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: themeData.primaryColor,
                                    height: MediaQuery.of(context).padding.top,
                                  ),
                                ),

                                // Users List Widget
                                _buildUserAvatarsList(
                                    friendsList, friendsDataList),

                                // Map Loading indicator
                                Opacity(
                                    opacity: _isMapLoading ? 1.0 : 0.0,
                                    child: Center(child: Loading()))
                              ],
                            );
                          } else if (snapshot.hasError) {
                            print(
                                'Error retrieving users for Map: ${snapshot.error.toString()}');
                            return Center(
                                child: Text('Unable to retrieve users'));
                          } else {
                            return Center(child: Loading());
                          }
                        });
                  }),
            ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    print('onMapCreated');
    mapController.complete(controller);

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15.0)));

    print('Map created!');

    setState(() {
      _isMapLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
