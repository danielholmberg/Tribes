import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/core/profile/widgets/created_posts/created_posts_view.dart';
import 'package:tribes/core/profile/widgets/joined_tribes/joined_tribes_view.dart';
import 'package:tribes/core/profile/widgets/liked_posts/liked_posts_view.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/services/firebase/storage_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/loading.dart';

class ProfileViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  TabController _tabController;
  Coordinates coordinates;
  Future<List<Address>> addressFuture;

  bool _isDialogView;
  MyUser _profileUser;
  File _imageFile;
  File _croppedImageFile;
  String _retrieveDataError;

  bool get isDialogView => _isDialogView;
  MyUser get currentUser => _databaseService.currentUserData;
  File get imageFile => _imageFile;
  File get croppedImageFile => _croppedImageFile;
  String get retrieveDataError => _retrieveDataError;
  bool get isAnotherUser => currentUser.id.compareTo(_profileUser.id) != 0;
  MyUser get profileUser => _profileUser;
  TabController get tabController => _tabController;
  Stream<List<Tribe>> get joinedTribes => _databaseService.joinedTribes;

  List<Tab> get tabs => isAnotherUser
      ? [Tab(icon: Icon(Icons.dashboard))]
      : [
          Tab(icon: Icon(Icons.dashboard)),
          Tab(icon: Icon(FontAwesomeIcons.solidHeart)),
          Tab(icon: Icon(FontAwesomeIcons.home))
        ];

  List<Widget> get tabBarViews => isAnotherUser
      ? [CreatedPosts(user: profileUser, viewOnly: isAnotherUser)]
      : [
          CreatedPosts(user: profileUser, viewOnly: isAnotherUser),
          LikedPosts(),
          JoinedTribes(),
        ];

  void initState(MyUser user, TickerProvider vsync) {
    _isDialogView = user != null;
    _profileUser = user ?? currentUser;

    _tabController = TabController(vsync: vsync, length: isAnotherUser ? 1 : 3);

    if (isAnotherUser) {
      if ((profileUser.lat != 0 && profileUser.lng != 0)) {
        coordinates = Coordinates(profileUser.lat, profileUser.lng);
        addressFuture =
            Geocoder.local.findAddressesFromCoordinates(coordinates);
      }
    } else {
      if ((currentUser.lat != 0 && currentUser.lng != 0)) {
        coordinates = Coordinates(currentUser.lat, currentUser.lng);
        addressFuture =
            Geocoder.local.findAddressesFromCoordinates(coordinates);
      }
    }
  }

  void setImageFile(File file) => _imageFile = file;
  void setCroppedImageFile(File file) => _croppedImageFile = file;

  void chooseNewProfilePic() async {
    try {
      final PickedFile pickedFile =
          await ImagePicker().getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);

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
              //activeWidgetColor: Constants.primaryColor,
              activeControlsWidgetColor: Constants.primaryColor,
              backgroundColor: Constants.primaryColor,
              dimmedLayerColor: Colors.black54,
            ),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));

        if (_croppedImageFile != null) {
          await _storageService.uploadUserImage(_croppedImageFile,
              currentUser.hasUserPic ? currentUser.picURL : null);
          setCroppedImageFile(_croppedImageFile);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await ImagePicker().getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setImageFile(File(response.file.path));
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  Widget placeholderPic() {
    return CachedNetworkImage(
      imageUrl: isAnotherUser ? profileUser.picURL : currentUser.picURL,
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
              child: Center(child: Loading()))
          : placeholderPic();
    } else {
      return placeholderPic();
    }
  }

  void onCloseProfile() {
    _navigationService.back();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
