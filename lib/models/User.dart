import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String info;
  final double lat;
  final double lng;

  UserData({this.uid, this.name, this.username, this.info, this.lat, this.lng});

  factory UserData.fromSnapshot(DocumentSnapshot doc) {
    return UserData(
      uid: doc.documentID,
      name: doc.data['name'] ?? '',
      username: doc.data['username'] ?? '',
      info: doc.data['info'] ?? '',
      lat: doc.data['lat'] ?? 58.4167,
      lng: doc.data['lng'] ?? 15.6167,
    );
  }

  @override
  String toString() {
    return '[$uid, $name, $username, $info, $lat, $lng]';
  }

}