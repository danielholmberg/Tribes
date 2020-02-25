import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/dialogs/ProfileSettings.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/CreatedPosts.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/LikedPosts.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Profile extends StatefulWidget {
  static const routeName = '/home/profile';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {

  TabController _tabController;
  Coordinates coordinates;
  Future<List<Address>> addressFuture;

  File _imageFile;
  File _croppedImageFile;
  String _retrieveDataError;
  bool loading = false;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    if((currentUser.lat != 0 && currentUser.lng != 0)) {
      coordinates = Coordinates(currentUser.lat, currentUser.lng);
      addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
    }

    _chooseNewProfilePic() async {
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
              toolbarColor: DynamicTheme.of(context).data.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              activeWidgetColor: DynamicTheme.of(context).data.primaryColor,
              activeControlsWidgetColor: DynamicTheme.of(context).data.primaryColor,
              backgroundColor: DynamicTheme.of(context).data.primaryColor,
              dimmedLayerColor: Colors.black54,
            ),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            )
          );

          if(_croppedImageFile != null) {
            setState(() {
              loading = true;
            });
            await StorageService().uploadUserImage(_croppedImageFile, currentUser.picURL);
            setState(() {
              loading = false;
              _croppedImageFile = _croppedImageFile;
            });
          }
        }
      } catch (e) {
        print(e.toString());
      }
    }

    _placeholderPic() {
      return CachedNetworkImage(
        imageUrl: currentUser.picURL,
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
          child: Center(child: Icon(Icons.error)),
        ),
      );
    }

    _profilePicture() {
      if (_retrieveDataError != null) {
        _retrieveDataError = null;
        return CircleAvatar(
          radius: Constants.profilePagePicRadius,
          backgroundColor: Colors.transparent,
          child: Center(child: Icon(Icons.error)),
        );
      }
      if (_croppedImageFile != null) {
        return loading 
        ? CircleAvatar(
          radius: Constants.profilePagePicRadius,
          child: Center(child: CircularProgressIndicator())
        ) : _placeholderPic();
      } else {
        return _placeholderPic();
      }
    }

    Future<void> retrieveLostData() async {
      final LostDataResponse response = await ImagePicker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      if (response.file != null) {
        setState(() {
          _imageFile = response.file;
        });
      } else {
        _retrieveDataError = response.exception.code;
      }
    }

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
                  onTap: () => loading ? null : _chooseNewProfilePic(),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: DynamicTheme.of(context).data.backgroundColor, width: 2.0),
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Platform.isAndroid
                          ? FutureBuilder<void>(
                            future: retrieveLostData(),
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
                              return _profilePicture();
                            },
                          ) : _profilePicture(),
                      ),
                      Positioned(
                        bottom: 0, 
                        right: 0, 
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: DynamicTheme.of(context).data.backgroundColor, width: 2.0),
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(Constants.maxCornerRadius),
                            child: Padding(
                              padding:EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.add,
                                size: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().postsPublishedByUser(currentUser.uid),
                  builder: (context, snapshot) {
                    String publishedCount = snapshot.hasData ? '${snapshot.data.documents.length}' : '0';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(publishedCount, style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                        Text('Published', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                      ],
                    );
                  }
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('${currentUser.likedPosts.length}', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                    Text('Liked', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                  ],
                ),
                Spacer(),
                StreamBuilder<List<Tribe>>(
                  stream: DatabaseService().joinedTribes(currentUser.uid),
                  builder: (context, snapshot) {
                    List<Tribe> tribesList =
                        snapshot.hasData ? snapshot.data : [];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('${tribesList.length}', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
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
                  Text(currentUser.name,
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
                      Icon(Icons.email, 
                        color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.7),
                        size: Constants.smallIconSize,
                      ),
                      SizedBox(width: Constants.defaultPadding),
                      Text(currentUser.email,
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
                      Icon(Icons.person_pin_circle, 
                        color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.7),
                        size: Constants.smallIconSize,
                      ),
                      SizedBox(width: Constants.defaultPadding),
                      FutureBuilder(
                        future: addressFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var addresses = snapshot.data;
                            var first = addresses.first;
                            var location = '${first.addressLine}';
                            print('lat ${currentUser.lat}, lng ${currentUser.lng}');
                            print('location: $location');
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
              Divider(),
              Visibility(
                visible: currentUser.info.isNotEmpty,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(currentUser.info,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      body: SafeArea(
        bottom: false,
          child: Container(
          child: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 350,
                    floating: false,
                    pinned: false,
                    elevation: 4.0,
                    backgroundColor: DynamicTheme.of(context).data.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
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
                                      Text(currentUser.username,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        )
                                      ),
                                    ],
                                  ),
                                  Positioned(right: 0, 
                                    child: IconButton(
                                      color: DynamicTheme.of(context).data.buttonColor,
                                      icon: Icon(Icons.settings, color: Constants.buttonIconColor),
                                      splashColor: Colors.transparent,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                            contentPadding: EdgeInsets.all(0.0),
                                            backgroundColor: Constants.profileSettingsBackgroundColor,
                                            content: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius)),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: MediaQuery.of(context).size.height * 0.8,
                                                alignment: Alignment.topLeft,
                                                child: ProfileSettings(user: currentUser),
                                              ),
                                            ),
                                          ),
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
                color: DynamicTheme.of(context).data.backgroundColor.withOpacity(0.8),
                child: Column(
                  children: <Widget>[
                    Container(
                      color: DynamicTheme.of(context).data.primaryColor,
                      child: TabBar(
                        labelColor: Constants.buttonIconColor,
                        indicatorColor: Constants.buttonIconColor,
                        unselectedLabelColor: Constants.buttonIconColor.withOpacity(0.7),
                        tabs: [
                          Tab(icon: Icon(Icons.dashboard)),
                          Tab(icon: Icon(Icons.favorite)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          CreatedPosts(),
                          LikedPosts(),
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
