import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class MapViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();

  // Old Town @ Stockholm,Sweden
  final LatLng _initialPosition =
      new LatLng(Constants.initialLat, Constants.initialLng);
  final Completer<GoogleMapController> _mapController =
      new Completer<GoogleMapController>();

  StreamSubscription<Position> _positionStream;

  bool _isMapLoading = true;
  bool _showMap = false;

  LatLng get initialPosition => _initialPosition;
  Completer<GoogleMapController> get mapController => _mapController;

  bool get isMapLoading => _isMapLoading;
  bool get showMap => _showMap;

  MyUser get currentUser => _databaseService.currentUserData;

  void initState({@required bool isMounted}) {
    _positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ).listen((Position position) async {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      if (position != null) {
        await _databaseService.updateUserLocation(
          position.latitude,
          position.longitude,
        );
      }
    });

    if (isMounted) {
      _showMap = true;
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    print('onMapCreated');
    _mapController.complete(controller);

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15.0)));

    print('Map created!');

    _isMapLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
