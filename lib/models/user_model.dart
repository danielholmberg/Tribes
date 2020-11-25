import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:tribes/shared/constants.dart' as Constants;

// User class to check Authentication status
class MyUser {

  final String id;
  final String name;
  final String username;
  final String email;
  final String info;
  final String picURL;
  final double lat;
  final double lng;
  final List<String> createdPosts;
  final List<String> likedPosts;

  MyUser({
    @required this.id, 
    this.name, 
    this.username, 
    this.email,
    this.info, 
    this.picURL,
    this.lat, 
    this.lng, 
    this.createdPosts,
    this.likedPosts
  });

  factory MyUser.fromSnapshot(DocumentSnapshot doc) {
    return MyUser(
      id: doc.id,
      name: doc.data()['name'] ?? '',
      username: doc.data()['username'] ?? '',
      email: doc.data()['email'] ?? '',
      info: doc.data()['info'] ?? '',
      picURL: doc.data()['picURL'] ?? Constants.placeholderPicURL,
      lat: doc.data()['lat'] ?? Constants.initialLat,
      lng: doc.data()['lng'] ?? Constants.initialLng,
      createdPosts: List.from(doc.data()['createdPosts'] ?? []),
      likedPosts: List.from(doc.data()['likedPosts'] ?? []),
    );
  }

  bool get hasUserPic => picURL != Constants.placeholderPicURL;
  bool get hasUsername => username.trim().isNotEmpty;

  @override
  String toString() {
    return '[$id, $name, $username, $info, $lat, $lng, $createdPosts, $likedPosts]';
  }

}

class MyUserLocationMarker {

  final double lat;
  final double lng;

  MyUserLocationMarker({this.lat, this.lng});

  factory MyUserLocationMarker.fromSnapshot(DocumentSnapshot doc) {
    return MyUserLocationMarker(
      lat: doc.data()['lat'],
      lng: doc.data()['lng'],
    );
  }

}
