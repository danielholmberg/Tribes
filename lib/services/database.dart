import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tribes/models/Message.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class DatabaseService {
  // Users Ref
  final CollectionReference usersRoot = Firestore.instance.collection('users');

  // Posts Ref
  final CollectionReference postsRoot = Firestore.instance.collection('posts');

  // Tribes Ref
  final CollectionReference tribesRoot = Firestore.instance.collection('tribes');

  // Chats Ref
  final CollectionReference chatsRoot = Firestore.instance.collection('chats');

  // Firebase Cloud Messaging
  final FirebaseMessaging fcm = FirebaseMessaging();

  Future createUserDocument(String uid, String name, String username, String email) {
    var data = {
      'name': name,
      'username': username,
      'email': email,
      'picURL': Constants.placeholderPicURL,
      'created': new DateTime.now().millisecondsSinceEpoch
    };
    print('Creating user with info: $data');

    return usersRoot
        .document(uid)
        .setData(data);
  }

  Future saveFCMToken() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    // Get the token for this device
    String fcmToken = await fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = Firestore.instance
          .collection('users')
          .document(currentUser.uid)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  Future updateUserData(String uid, String name, String username, String email,
    String info, double lat, double lng) async {
    
    var data = {
      'name': name,
      'username': username,
      'email': email,
      'info': info,
      'lat': lat,
      'lng': lng,
    };
    print('New profile data: $data');

    return usersRoot.document(uid).updateData(data);
  }

  Future updateUserPicURL(String picURL) async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    if (currentUser != null) {
      return usersRoot.document(currentUser.uid).updateData({'picURL': picURL});
    } else {
      return null;
    }    
  }

  Future updateUserLocation(double lat, double lng) async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    if (currentUser != null) {
      print('Updating current user location in Firebase: [$lat, $lng]');
      return usersRoot
          .document(currentUser.uid)
          .updateData({'lat': lat, 'lng': lng});
    } else {
      print('Failed to update user location!');
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
    return tribesRoot.where('members', arrayContains: userID).orderBy('created', descending: true).snapshots().map(
        (list) =>
            list.documents.map((doc) => Tribe.fromSnapshot(doc)).toList());
  }

  // Get not yet joined Tribes Stream
  Stream<List<Tribe>> notYetJoinedTribes(String userID) {
    return tribesRoot.snapshots().map((list) => list.documents.map((doc) => Tribe.fromSnapshot(doc))
    .where((tribe) => !tribe.members.contains(userID)).toList());
  }

  // Get Posts Stream related to a specific Tribe
  // Return QuerySnapshot to make it work with FirebaseAnimatedList.
  Stream<QuerySnapshot> posts(String tribeID) {
    // Chaining .where() and .orderBy() requires a Composite-index in Firebase Firestore setup.
    // See https://github.com/flutter/flutter/issues/15928#issuecomment-394197426 for more info.
    return postsRoot.where('tribeID', isEqualTo: tribeID).orderBy('created', descending: true).snapshots();
  }

  // Add a new Post
  Future addNewPost(String author, String title, String content, List<String> images, String tribeID) async {
    DocumentReference postRef = postsRoot.document();
    Position currentPosition;

    if(await Geolocator().isLocationServiceEnabled()) {
      currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      var data = {
        'author': author,
        'title': title,
        'content': content,
        'tribeID': tribeID,
        'images': images,
        'lat': currentPosition.latitude,
        'lng': currentPosition.longitude,
        'created': new DateTime.now().millisecondsSinceEpoch,
      };

      print('Publishing post: $data');
      return postRef.setData(data);
    } else {
      var data = {
        'author': author,
        'title': title,
        'content': content,
        'tribeID': tribeID,
        'images': images,
        'created': new DateTime.now().millisecondsSinceEpoch,
      };

      print('Publishing post: $data');
      return postRef.setData(data);
    }

    
  }

  Future deletePost(Post post) async {
    if(post.images.isNotEmpty) await Future.forEach(post.images, (imageURL) async => await StorageService().deleteFile(imageURL)); 
    return postsRoot.document(post.id).delete();
  }

  Future updatePostData(String id, String title, String content, List<String> images) {
    var data = {
      'title': title,
      'content': content,
      'images': images,
      'updated': new DateTime.now().millisecondsSinceEpoch,
    };
    print('Updated Post data: $data');

    return postsRoot.document(id).updateData(data);
  }

  Future createNewTribe(String userID, String name, String desc, String color, String imageURL) {

    var rng = new Random();
    var password = rng.nextInt(900000) + 100000;

    var data = {
      'name': name,
      'desc': desc,
      'members': [userID],
      'founder': userID,
      'password': '$password',
      'color': color,
      'imageURL': imageURL,
      'updated': new DateTime.now().millisecondsSinceEpoch,
      'created': new DateTime.now().millisecondsSinceEpoch,
    };

    print('Creating new Tribe: $data');
    return tribesRoot.document().setData(data);
  }

  Future updateTribeData(String id, String name, String desc, String color, String imageURL) {
    var data = {
      'name': name,
      'desc': desc,
      'color': color,
      'imageURL': imageURL,
      'updated': new DateTime.now().millisecondsSinceEpoch,
    };

    print('New profile data: $data');
    return tribesRoot.document(id).updateData(data);
  }

  Future deleteTribe(String id) {
    return tribesRoot.document(id).delete();
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

  Future unlikePost(String userID, String postID) {
    usersRoot.document(userID).updateData({'likedPosts': FieldValue.arrayRemove([postID])});
    return postsRoot.document(postID).updateData({'likes': FieldValue.increment(-1)});
  }

  Future likePost(String userID, String postID) {
    usersRoot.document(userID).updateData({'likedPosts': FieldValue.arrayUnion([postID])});
    return postsRoot.document(postID).updateData({'likes': FieldValue.increment(1)});
  }

  Stream<Post> post(String userID, String postID) {
    return postsRoot.document(postID).snapshots().map((postData) { 
      if(!postData.exists) {
        usersRoot.document(userID).updateData({'likedPosts': FieldValue.arrayRemove([postID])});
      } 

      return Post.fromSnapshot(postData);
    });
  }

  // Return QuerySnapshot to make it work with FirebaseAnimatedList.
  Stream<QuerySnapshot> postsPublishedByUser(String userID) {
    // Chaining .where() and .orderBy() requires a Composite-index in Firebase Firestore setup.
    // See https://github.com/flutter/flutter/issues/15928#issuecomment-394197426 for more info.
    return postsRoot.where('author', isEqualTo: userID).orderBy('created', descending: true).snapshots();
  }

  Future addUserToTribe(String userID, String tribeID) {
    fcm.subscribeToTopic(tribeID);
    return tribesRoot.document(tribeID).updateData({'members': FieldValue.arrayUnion([userID])});
  }

  Future leaveTribe(String userID, String tribeID) {
    fcm.unsubscribeFromTopic(tribeID);
    return tribesRoot.document(tribeID).updateData({'members': FieldValue.arrayRemove([userID])});
  }

  Stream<Message> mostRecentMessage(String roomID) {
    return chatsRoot.document(roomID).collection('messages').limit(1).orderBy('created', descending: true).snapshots()
    .map((list) => list.documents.map((messageDoc) => Message.fromSnapshot(messageDoc)).first);
  }

  Stream<QuerySnapshot> fiveLatestMessages(String tribeID) {
    return chatsRoot.document(tribeID).collection('messages').limit(5).orderBy('created', descending: true).snapshots();
  }

  Stream<QuerySnapshot> allMessages(String roomID) {
    return chatsRoot.document(roomID).collection('messages').orderBy('created', descending: true).snapshots();
  }

  Stream<QuerySnapshot> privateChatRooms(String userID) {
    return chatsRoot.where('members', arrayContains: userID).where('hasMessages', isEqualTo: true).snapshots();
  }

  Future<String> createNewPrivateChatRoom(String userID, String friendID) async {
    String roomID = userID.hashCode <= friendID.hashCode ? '$userID-$friendID' : '$friendID-$userID';

    bool roomAlreadyExists = false;
    await chatsRoot.document(roomID).get().then((onValue) => roomAlreadyExists = onValue.exists);

    if(!roomAlreadyExists) {
      var data = {
        'members': [userID, friendID],
      };

      print('Creating new chat room data: $data');
      chatsRoot.document(roomID).setData(data);
    }

    fcm.subscribeToTopic(roomID);

    return Future.value(roomID);
  }

  Future sendMessage(String roomID, String userID, String message) {
    var data = {
      'message': message,
      'senderID': userID,
      'created': new DateTime.now().millisecondsSinceEpoch,
    };
    print('Sending message data: $data');

    DocumentReference messageRef = chatsRoot.document(roomID).collection('messages').document();
    chatsRoot.document(roomID).updateData({'hasMessages': true});

    return Firestore.instance.runTransaction((transaction) => transaction.set(messageRef, data));
  }

  Future<List<Tribe>> joinedTribesFuture(String userID) async {
    return tribesRoot.where('members', arrayContains: userID).getDocuments().then((list) =>
      list.documents.map((doc) => Tribe.fromSnapshot(doc)).toList()
    );
  }

  Future<List<UserData>> friendsList(String userID) async {
    List<UserData> _friends = [];
    List<String> _alreadyAddedFriendIDs = [];
    List<Tribe> _joinedTribes = await joinedTribesFuture(userID);

    for(final tribe in _joinedTribes) {
      print('Looking at tribe: ${tribe.name}');
      for(final memberID in tribe.members) {
        if(memberID != userID) {
          if(!_alreadyAddedFriendIDs.contains(memberID)) {
            print('Adding friend: $memberID');
            UserData friend = await usersRoot.document(memberID).get().then((doc) => UserData.fromSnapshot(doc));
            _friends.add(friend);
            _alreadyAddedFriendIDs.add(memberID);
          }
        }
      }
    }

    print('friends: $_friends');
    return _friends;

  }

}
