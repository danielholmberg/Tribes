import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';

class Map extends StatefulWidget {
  
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with AutomaticKeepAliveClientMixin {
  
  GoogleMapController mapController;
  LatLng _initialPosition = LatLng(58.4167, 15.6167);
  bool loadingMap = true;

  StreamSubscription<Position> positionStream = Geolocator().getPositionStream(
    LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10)).listen((Position position) async {
        print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
        if(position != null) {
          
          //await DatabaseService().updateUserLocation( position.latitude, position.longitude);
        }
    }
  );

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      loadingMap = false;
    });

    Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15.0)
    ));
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
            GoogleMap(
              padding: EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 11.0,
              ),
            ),
            loadingMap 
            ? Container(
              color: DynamicTheme.of(context).data.backgroundColor,
              child: Center(child: CircularProgressIndicator())
            ) 
            : Text('Map'),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}