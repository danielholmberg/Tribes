import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with AutomaticKeepAliveClientMixin {
  // Old Town @ Stockholm,Sweden
  LatLng _initialPosition = LatLng(Constants.initialLat, Constants.initialLng);

  GoogleMapController mapController;
  bool showGoogleMaps = false;
  BitmapDescriptor markerIcon;

  StreamSubscription<Position> positionStream = Geolocator()
      .getPositionStream(
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10))
      .listen((Position position) async {
    print(position == null
        ? 'Unknown'
        : position.latitude.toString() + ', ' + position.longitude.toString());
    if (position != null) {
      dynamic result = await DatabaseService()
          .updateUserLocation(position.latitude, position.longitude);
      if (result == null) print('Failed to update user location!');
    }
  });

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });

    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15.0)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        showGoogleMaps = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserData>(context);
    print('Building Map()...');
    print('Current user ${currentUser.toString()}');

    return Container(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            showGoogleMaps
                ? StreamBuilder<List<Tribe>>(
                    stream: DatabaseService().joinedTribes(currentUser.uid),
                    builder: (context, snapshot) {
                      List<Tribe> tribesList =
                          snapshot.hasData ? snapshot.data : [];

                      return StreamBuilder<List<UserData>>(
                          stream: DatabaseService().users,
                          builder: (context, snapshot) {
                            List<UserData> membersList =
                                snapshot.hasData ? snapshot.data : [];
                            Set<Marker> markers = Set<Marker>();

                            for (int i = 0; i < membersList.length; i++) {
                              UserData user = membersList[i];

                              tribesList.forEach((Tribe tribe) {
                                if (tribe.members.contains(user.uid)) {
                                  markers.add(Marker(
                                    markerId: MarkerId(user.uid),
                                    position: LatLng(user.lat, user.lng),
                                    icon: markerIcon,
                                    infoWindow: InfoWindow(
                                      title: user.username,
                                    ),
                                  ));
                                }
                              });
                            }

                            return GoogleMap(
                              padding: EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
                              onMapCreated: _onMapCreated,
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: _initialPosition,
                                zoom: 5.0,
                              ),
                              markers: markers,
                            );
                          });
                    })
                : Container(
                    color: DynamicTheme.of(context).data.backgroundColor,
                    child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
