import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
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
      child: currentUser == null ? Loading() : Scaffold(
        body: StreamBuilder<List<Tribe>>(
          stream: DatabaseService().joinedTribes(currentUser.uid),
          builder: (context, snapshot) {
            List<Tribe> tribesList = snapshot.hasData ? snapshot.data : [];
            
            // TO-DO: Change to only listen to a stream of relevant users instead of ALL users. 
            return StreamBuilder<List<UserData>>(
              stream: DatabaseService().users,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  List<UserData> usersList = snapshot.data;
                  List<String> friendsList = [];
                  List<UserData> friendsDataList = [];
                  Set<Marker> markers = Set<Marker>();

                  tribesList.forEach((tribe) => friendsList.addAll(tribe.members.where((memberID) => (!friendsList.contains(memberID) && currentUser.uid != memberID))));
                  
                  friendsList.forEach((friendID) => friendsDataList.add(usersList.singleWhere((user) => user.uid == friendID)));
                  friendsDataList.forEach((friendData) => markers.add(Marker(
                      markerId: MarkerId(friendData.uid),
                      position: LatLng(friendData.lat, friendData.lng),
                      icon: markerIcon,
                      infoWindow: InfoWindow(
                        title: friendData.username,
                      ),
                    ))
                  );
                  
                  return Stack(
                    children: <Widget>[

                      // Google Map Stack Widget
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _isMapLoading ? 0.0 : 1.0,
                        child: GoogleMap(
                          padding: EdgeInsets.fromLTRB(6.0, 106.0, 6.0, Platform.isIOS ? 80 : 0.0),
                          onMapCreated: _onMapCreated,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition,
                            zoom: 5.0,
                          ),
                          markers: markers.toSet(),
                        ),
                      ),

                      // Statusbar background
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.5),
                          height: MediaQuery.of(context).padding.top,
                        ),
                      ),

                      // Users List Widget
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 90,
                                child: ScrollConfiguration(
                                  behavior: CustomScrollBehavior(),
                                  child: ListView.builder(
                                    shrinkWrap: false,
                                    padding: EdgeInsets.all(6.0),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: friendsList.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () async => await mapController.future.then((controller) =>
                                          controller.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: LatLng(friendsDataList[index].lat, friendsDataList[index].lng),
                                                zoom: 15.0
                                              )
                                            )
                                          )
                                        ),
                                        child: Container(
                                          height: 56,
                                          margin: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: DynamicTheme.of(context).data.backgroundColor,
                                            borderRadius: BorderRadius.circular(20.0),
                                            border: Border.all(color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.4), width: 2.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.5),
                                                blurRadius: 4.0,
                                                spreadRadius: 0.0,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: userAvatar(friendsDataList[index]),
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Map Loading indicator
                      Opacity(opacity: _isMapLoading ? 1.0 : 0.0, child: Center(child: CircularProgressIndicator()))   
                    ],
                  );
                } else if(snapshot.hasError){
                  print('Error retrieving users for Map: ${snapshot.error.toString()}');
                  return Center(child: Text('Unable to retrieve users'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }
            );
          }
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
