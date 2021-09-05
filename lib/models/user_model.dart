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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MyUser(
      id: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      info: data['info'] ?? '',
      picURL: data['picURL'] ?? Constants.placeholderPicURL,
      lat: data['lat'] ?? Constants.initialLat,
      lng: data['lng'] ?? Constants.initialLng,
      createdPosts: List.from(data['createdPosts'] ?? []),
      likedPosts: List.from(data['likedPosts'] ?? []),
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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MyUserLocationMarker(
      lat: data['lat'],
      lng: data['lng'],
    );
  }

}
