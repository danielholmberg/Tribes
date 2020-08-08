import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/services/firebase_auth_service.dart';
import 'package:tribes/services/storage_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/loading.dart';

/* 
* Handels all logic. 
* Utilizes Services to provide functionality.
*/
class ProfileViewModel extends StreamViewModel<UserData> {
  final UserData user;
  ProfileViewModel({this.user});

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final StorageService _storageService = locator<StorageService>();
  // -------------- Services [END] --------------- //
  
  // -------------- Models [START] --------------- //
  TabController _tabController;
  Coordinates coordinates;
  Future<List<Address>> addressFuture;
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  File _imageFile;
  File _croppedImageFile;
  String _retrieveDataError;

  void initState(TickerProvider vsync) {
    _tabController = TabController(vsync: vsync, length: 3);
    

    if(isAnotherUser) {
      if((otherUser.lat != 0 && otherUser.lng != 0)) {
        coordinates = Coordinates(otherUser.lat, otherUser.lng);
        addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
      }
    } else {
      if((currentUser.lat != 0 && currentUser.lng != 0)) {
        coordinates = Coordinates(currentUser.lat, currentUser.lng);
        addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  void setImageFile(File file) => _imageFile = file;
  void setCroppedImageFile(File file) => _croppedImageFile = file;
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  UserData get currentUser => _databaseService.currentUserData;
  File get imageFile => _imageFile;
  File get croppedImageFile => _croppedImageFile;
  String get retrieveDataError => _retrieveDataError;
  bool get isAnotherUser => user != null;
  UserData get otherUser => user;
  TabController get tabController => _tabController;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  void chooseNewProfilePic() async {
    try {
      _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

      if(_imageFile != null) {
        _croppedImageFile = await ImageCropper.cropImage(
          sourcePath: _imageFile.path,
          cropStyle: CropStyle.circle,
          compressQuality: 100,
          compressFormat: ImageCompressFormat.png,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop picture',
            toolbarColor: Constants.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeWidgetColor: Constants.primaryColor,
            activeControlsWidgetColor: Constants.primaryColor,
            backgroundColor: Constants.primaryColor,
            dimmedLayerColor: Colors.black54,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        );

        if(_croppedImageFile != null) {
          await _storageService.uploadUserImage(_croppedImageFile, currentUser.hasUserPic() ? currentUser.picURL : null);
          setCroppedImageFile(_croppedImageFile);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setImageFile(response.file);
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  Widget placeholderPic() {
    return CachedNetworkImage(
      imageUrl: isAnotherUser ? otherUser.picURL : currentUser.picURL,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: Constants.profilePagePicRadius,
        backgroundImage: imageProvider,
        backgroundColor: Colors.transparent,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: Constants.profilePagePicRadius,
        backgroundColor: Colors.transparent,
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: Constants.profilePagePicRadius,
        backgroundColor: Colors.transparent,
        child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)),
      ),
    );
  }

  Widget profilePicture() {
    if (_retrieveDataError != null) {
      _retrieveDataError = null;
      return CircleAvatar(
        radius: Constants.profilePagePicRadius,
        backgroundColor: Colors.transparent,
        child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)),
      );
    }
    if (_croppedImageFile != null) {
      return isBusy 
      ? CircleAvatar(
        radius: Constants.profilePagePicRadius,
        child: Center(child: Loading())
      ) : placeholderPic();
    } else {
      return placeholderPic();
    }
  }
  // -------------- Logic [END] --------------- //

  @override
  void onData(UserData data) {
    print('data: ${data.toString()}');
    super.onData(data);
  }

  @override
  Stream<UserData> get stream => _databaseService.currentUserDataStream();

}