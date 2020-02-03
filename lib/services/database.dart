import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';

class DatabaseService {
  // Users Ref
  final CollectionReference usersRoot = Firestore.instance.collection('users');

  // Posts Ref
  final CollectionReference postsRoot = Firestore.instance.collection('posts');

  // Tribes Ref
  final CollectionReference tribesRoot =
      Firestore.instance.collection('tribes');

  Future createUserDocument(String uid) async {
    return usersRoot
        .document(uid)
        .setData({'created': new DateTime.now().millisecondsSinceEpoch});
  }

  Future updateUserData(String uid, String name, String username, String info,
      double lat, double lng) async {
    var data = {
      'name': name,
      'username': username,
      'info': info,
      'lat': lat,
      'lng': lng,
    };
    print('New profile data: $data');

    return await usersRoot.document(uid).updateData(data);
  }

  Future updateUserLocation(double lat, double lng) async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    if (currentUser != null) {
      print('Updating current user location in Firebase: [$lat, $lng]');
      return await usersRoot
          .document(currentUser.uid)
          .updateData({'lat': lat, 'lng': lng});
    } else {
      return null;
    }
  }

  Stream<List<UserData>> membersData(String tribeID) {
    return tribesRoot.document(tribeID).snapshots().map((tribeData) =>
        tribeData.data['members'].map((userID) => usersRoot
            .document(userID)
            .snapshots()
            .map((userData) => UserData.fromSnapshot(userData))
            .toList()));
  }

  Stream<List<UserData>> get users {
    return usersRoot.snapshots().map((list) => list.documents
        .map((userData) => UserData.fromSnapshot(userData))
        .toList());
  }

  // Get joined Tribes Stream
  Stream<List<Tribe>> joinedTribes(String userID) {
    return tribesRoot.where('members', arrayContains: userID).snapshots().map(
        (list) =>
            list.documents.map((doc) => Tribe.fromSnapshot(doc)).toList());
  }

  // Get Posts Stream related to a specific Tribe
  // Return QuerySnapshot to make it work with FirebaseAnimatedList.
  Stream<QuerySnapshot> posts(String tribeID) {
    // Chaining .where() and .orderBy() requires a Composite-index in Firebase Firestore setup.
    // See https://github.com/flutter/flutter/issues/15928#issuecomment-394197426 for more info.
    return postsRoot.where('tribeID', isEqualTo: tribeID).orderBy('created', descending: true).snapshots();
  }

  // Add a new Post
  Future addNewPost(
      String author, String title, String content, String fileURL, String tribeID) async {
    DocumentReference postRef = postsRoot.document();

    Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    var data = {
      'author': author,
      'title': title,
      'content': content,
      'tribeID': tribeID,
      'fileURL': fileURL,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'created': new DateTime.now().millisecondsSinceEpoch,
    };

    print('Publishing post: $data');
    return await postRef.setData(data);
  }

  Future deletePost(String id) async {
    return await postsRoot.document(id).delete();
  }

  Future updatePostData(String id, String title, String content) async {
    var data = {
      'title': title,
      'content': content,
      'updated': new DateTime.now().millisecondsSinceEpoch,
    };
    print('Updated Post data: $data');

    return await postsRoot.document(id).updateData(data);
  }

  Future createNewTribe(
      String name, String desc, String color, String imageURL) async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

    var data = {
      'name': name,
      'desc': desc,
      'members': [currentUser.uid],
      'founder': currentUser.uid,
      'color': color,
      'imageURL': imageURL,
      'updated': new DateTime.now().millisecondsSinceEpoch,
      'created': new DateTime.now().millisecondsSinceEpoch,
    };

    try {
      print('Creating new Tribe: $data');
      await tribesRoot.document().setData(data);
      return true;
    } catch (e) {
      print('Failed with error: ${e.toString()}');
      return false;
    }
  }

  Future updateTribeData(String id, String name, String desc, String color,
      String imageURL) async {
    var data = {
      'name': name,
      'desc': desc,
      'color': color,
      'imageURL': imageURL,
      'updated': new DateTime.now().millisecondsSinceEpoch,
    };

    print('New profile data: $data');
    return await tribesRoot.document(id).updateData(data);
  }

  Future deleteTribe(String id) async {
    return await tribesRoot.document(id).delete();
  }

  Stream<Tribe> tribe(String tribeID) {
    return tribesRoot
        .document(tribeID)
        .snapshots()
        .map((doc) => Tribe.fromSnapshot(doc));
  }

  Stream<UserData> currentUser(String uid) {
    return usersRoot
        .document(uid)
        .snapshots()
        .map((snapshot) => UserData.fromSnapshot(snapshot));
  }

  Stream<UserData> userData(String uid) {
    return usersRoot
        .document(uid)
        .snapshots()
        .map((snapshot) => UserData.fromSnapshot(snapshot));
  }
}
