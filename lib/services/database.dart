import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tribes/models/ChatMessage.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/storage.dart';

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

  Future createUserDocument(String uid, String name, String email) {
    var data = {
      'name': name,
      'email': email,
      'created': FieldValue.serverTimestamp(),
    };
    print('Creating user with info: $data');

    return usersRoot.document(uid).setData(data, merge: true);
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

  Future<bool> updateUsername(String uid, String username) async {
    bool available = await checkUsernameAvailability(username);
    
    if(available) {
      print('New username ($uid): $username');
      usersRoot.document(uid).updateData({'username': username}); 
    }

    return Future.value(available);
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final result = await usersRoot.where('username', isEqualTo: username).getDocuments();
    return result.documents.isEmpty;
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
        (list) => list.documents.map((doc) => Tribe.fromSnapshot(doc)).toList());
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

  String generateNewPostID() {
    return postsRoot.document().documentID;
  }

  // Add a new Post
  Future addNewPost({
    String postID, 
    @required String author, 
    @required String title, 
    @required String content, 
    @required List<String> images, 
    @required String tribeID
  }) async {
    DocumentReference postRef = postsRoot.document(postID != null ? postID : generateNewPostID());
    Position currentPosition;
    
    var data = {
      'author': author,
      'title': title,
      'content': content,
      'tribeID': tribeID,
      'images': images,
      'likes': 1,
      'created': FieldValue.serverTimestamp(),
    };

    if(await Geolocator().isLocationServiceEnabled()) {
      currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      data.putIfAbsent('lat', () => currentPosition.latitude);
      data.putIfAbsent('lng', () => currentPosition.longitude);
    } 

    usersRoot.document(author).updateData({
      'createdPosts': FieldValue.arrayUnion([postRef.documentID]),
      'likedPosts': FieldValue.arrayUnion([postRef.documentID]),
    });

    print('Publishing post: $data');
    postRef.setData(data);

    return postRef.documentID;
  }

  Future deletePost(Post post) {
    if(post.images.isNotEmpty) StorageService().deletePostImages(post.id);
    usersRoot.document(post.author).updateData({'createdPosts': FieldValue.arrayRemove([post.id])});
    return postsRoot.document(post.id).delete();
  }

  Future updatePostData({
    @required String postID, 
    String title, 
    String content, 
    List<String> images
  }) {

    Map<String, dynamic> data = {
      'updated': FieldValue.serverTimestamp(),
    };

    if(title != null) {
      data.putIfAbsent('title', () => title);
    }
    if(content != null) {
      data.putIfAbsent('content', () => content);
    }
    if(images != null) {
      data.putIfAbsent('images', () => images);
    }

    print('Updated Post data: $data');

    return postsRoot.document(postID).updateData(data);
  }

  Stream<int> numberOfLikes(String postID) {
    return postsRoot.document(postID).get().then((doc) => Post.fromSnapshot(doc).likes).asStream();
  }

  Future createNewTribe(String userID, String name, String desc, String color, String imageURL, bool secret) {

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
      'secret': secret,
      'created': FieldValue.serverTimestamp(),
      'updated': FieldValue.serverTimestamp(),
    };

    print('Creating new Tribe: $data');
    DocumentReference tribeDoc = tribesRoot.document();
    fcm.subscribeToTopic(tribeDoc.documentID);
    
    return tribeDoc.setData(data);
  }

  Future updateTribeData(String id, String name, String desc, String color, String password, String imageURL, bool secret) {
    var data = {
      'name': name,
      'desc': desc,
      'color': color,
      'password': password,
      'imageURL': imageURL,
      'secret': secret,
      'updated': FieldValue.serverTimestamp(),
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
    return chatsRoot.where('members', arrayContains: userID).where('hasMessages', isEqualTo: true).orderBy('updated', descending: true).snapshots();
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

  Future sendChatMessage(String roomID, String userID, String message) {
    var data = {
      'message': message,
      'senderID': userID,
      'created': FieldValue.serverTimestamp(),
    };
    print('Sending message data: $data');

    DocumentReference roomRef = chatsRoot.document(roomID);
    DocumentReference messageRef = roomRef.collection('messages').document();

    return Firestore.instance.runTransaction((transaction) {
      return transaction.set(messageRef, data).then((onValue) {
        transaction.update(roomRef, {'hasMessages': true, 'updated': FieldValue.serverTimestamp()});
      });
    });
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

  Future<List<UserData>> tribeMembersList(List<String> members) async {
    List<UserData> membersList = [];

    for(String memberID in members) {
      await usersRoot.document(memberID).get().then((doc) => membersList.add(UserData.fromSnapshot(doc)));
    }

    return membersList;
  }

}
