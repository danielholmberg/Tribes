import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribes/shared/constants.dart' as Constants;

// User class to check Authentication status
class User {

  final String uid;
  User({this.uid});

}

// UserData class to provide User information throughout the application
class UserData {

  final String uid;
  final String name;
  final String username;
  final String email;
  final String info;
  final String picURL;
  final double lat;
  final double lng;
  final List<String> likedPosts;

  UserData({
    this.uid, 
    this.name, 
    this.username, 
    this.email,
    this.info, 
    this.picURL,
    this.lat, 
    this.lng, 
    this.likedPosts
  });

  factory UserData.fromSnapshot(DocumentSnapshot doc) {
    return UserData(
      uid: doc.documentID,
      name: doc.data['name'] ?? '',
      username: doc.data['username'] ?? '',
      email: doc.data['email'] ?? '',
      info: doc.data['info'] ?? '',
      picURL: doc.data['picURL'] ?? Constants.placeholderPicURL,
      lat: doc.data['lat'] ?? Constants.initialLat,
      lng: doc.data['lng'] ?? Constants.initialLng,
      likedPosts: List.from(doc.data['likedPosts'] ?? []),
    );
  }

  @override
  String toString() {
    return '[$uid, $name, $username, $info, $lat, $lng, $likedPosts]';
  }

}

class UserLocationMarker {

  final double lat;
  final double lng;

  UserLocationMarker({this.lat, this.lng});

  factory UserLocationMarker.fromSnapshot(DocumentSnapshot doc) {
    return UserLocationMarker(
      lat: doc.data['lat'],
      lng: doc.data['lng'],
    );
  }

}
