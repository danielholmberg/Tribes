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
import 'package:tribes/shared/widgets/Loading.dart';

class MyMap extends StatefulWidget {
  static const routeName = '/home/myMap';

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> with AutomaticKeepAliveClientMixin {
  // Old Town @ Stockholm,Sweden
  LatLng _initialPosition = LatLng(Constants.initialLat, Constants.initialLng);

  Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  bool _isMapLoading = true;
  BitmapDescriptor markerIcon;

  StreamSubscription<Position> positionStream = Geolocator().getPositionStream(
    LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10)).listen((Position position) async {
      print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      if (position != null) {
        dynamic result = await DatabaseService().updateUserLocation(position.latitude, position.longitude);
        if (result == null) print('Failed to update user location!');
      }
    }
  ); 

  void _onMapCreated(GoogleMapController controller) async {
    mapController.complete(controller);

    Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 15.0
        )
      )
    );

    setState(() {
      _isMapLoading = false;
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentUser = Provider.of<UserData>(context);
    print('Building Map()...');
    print('Current user ${currentUser.toString()}');

    return Container(
      child: Scaffold(
        body: Stack(
          children: <Widget>[

            // Google Map Widget
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isMapLoading ? 0.0 : 1.0,
              child: StreamBuilder<List<Tribe>>(
                stream: DatabaseService().joinedTribes(currentUser.uid),
                builder: (context, snapshot) {
                  List<Tribe> tribesList = snapshot.hasData ? snapshot.data : [];

                  return StreamBuilder<List<UserData>>(
                    stream: DatabaseService().users,
                    builder: (context, snapshot) {
                      List<UserData> membersList = snapshot.hasData ? snapshot.data : [];
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
                    }
                  );
                }),
            ),

            // Map Loading indicator
            Opacity(opacity: _isMapLoading ? 1.0 : 0.0, child: Center(child: CircularProgressIndicator()))   
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
