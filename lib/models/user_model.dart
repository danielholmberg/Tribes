import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribes/shared/constants.dart' as Constants;

// User class to check Authentication status
class User {

  final String id;
  User({this.id});

}

// UserData class to provide User information throughout the application
class UserData {

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

  UserData({
    this.id, 
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

  factory UserData.fromSnapshot(DocumentSnapshot doc) {
    return UserData(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      username: doc.data['username'] ?? '',
      email: doc.data['email'] ?? '',
      info: doc.data['info'] ?? '',
      picURL: doc.data['picURL'] ?? Constants.placeholderPicURL,
      lat: doc.data['lat'] ?? Constants.initialLat,
      lng: doc.data['lng'] ?? Constants.initialLng,
      createdPosts: List.from(doc.data['createdPosts'] ?? []),
      likedPosts: List.from(doc.data['likedPosts'] ?? []),
    );
  }

  bool hasUserPic() {
    return picURL != Constants.placeholderPicURL;
  }

  bool hasUsername() {
    return username.trim().isNotEmpty;
  }

  @override
  String toString() {
    return '[$id, $name, $username, $info, $lat, $lng, $createdPosts, $likedPosts]';
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