import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      return await usersRoot.document(currentUser.uid).updateData({'lat': lat,'lng': lng});
    } else {
      return null;
    }
  }

  Stream<List<UserData>> membersData(String tribeID) {
    return tribesRoot.document(tribeID).snapshots()
      .map((tribeData) => tribeData.data['members']
      .map((userID) => usersRoot.document(userID).snapshots()
      .map((userData) => UserData.fromSnapshot(userData))
      .toList()));
  }

  Stream<List<UserData>> get users {
    return usersRoot.snapshots().map(
      (list) => list.documents.map((userData) => UserData.fromSnapshot(userData)).toList());
  }

  // Get joined Tribes Stream
  Stream<List<Tribe>> joinedTribes(String userID) {
    return tribesRoot.where('members', arrayContains: userID).snapshots().map(
        (list) => list.documents.map((doc) => Tribe.fromSnapshot(doc)).toList());
  }

  // Get Posts Stream related to a specific Tribe
  Stream<QuerySnapshot> posts(String tribeID) {
    // Return QuerySnapshot to make it work with FirebaseAnimatedList.
    return postsRoot.where('tribeID', isEqualTo: tribeID).snapshots();
  }

  // Add a new Post
  Future addNewPost(
      String userID, String title, String content, String tribeID) async {
    DocumentReference postRef = postsRoot.document();

    var data = {
      'id': postRef.documentID,
      'userID': userID,
      'title': title,
      'content': content,
      'tribeID': tribeID,
      'created': new DateTime.now().millisecondsSinceEpoch,
    };

    print('Publishing post: $data');
    return await postRef.setData(data);
  }

  Stream<UserData> currentUser(String uid) {
    return usersRoot
        .document(uid)
        .snapshots()
        .map((snapshot) => UserData.fromSnapshot(snapshot));
  }

}
