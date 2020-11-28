import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/auth_service.dart';
import 'package:tribes/services/firebase/storage_service.dart';

class DatabaseService with ReactiveServiceMixin {
  // Users Ref
  final CollectionReference usersRoot =
      FirebaseFirestore.instance.collection('users');

  // Posts Ref
  final CollectionReference postsRoot =
      FirebaseFirestore.instance.collection('posts');

  // Tribes Ref
  final CollectionReference tribesRoot =
      FirebaseFirestore.instance.collection('tribes');

  // Chats Ref
  final CollectionReference chatsRoot =
      FirebaseFirestore.instance.collection('chats');

  // Firebase Cloud Messaging
  final FirebaseMessaging fcm = FirebaseMessaging();

  // Current User Data
  RxValue<MyUser> _currentUserData = RxValue<MyUser>(initial: null);
  MyUser get currentUserData => _currentUserData.value;

  StreamSubscription _userStreamSub;

  // ignore: close_sinks
  final StreamController<MyUser> userStreamController =
      StreamController<MyUser>.broadcast();
  Stream<MyUser> get userStream =>
      userStreamController.stream.asBroadcastStream();

  DatabaseService() {
    listenToReactiveValues([
      _currentUserData,
    ]);
  }

  void initListener(String userId) {
    print('Initializing Database listener...');
    _userStreamSub = usersRoot.doc(userId).snapshots().listen(
      (DocumentSnapshot userDoc) {
        _currentUserData.value = MyUser.fromSnapshot(userDoc);
        notifyListeners();
      },
    );
    print('Success!');
  }

  void disposeListener() {
    print('Dispose Database listener...');
    _userStreamSub.cancel();
    print('Success!');
  }

  void resetCurrentUser() {
    _currentUserData.value = null;
  }

  Future createUserDocument(String uid, String name, String email) {
    var data = {
      'name': name,
      'email': email,
      'created': FieldValue.serverTimestamp(),
    };
    print('Creating user with info: $data');

    return usersRoot.doc(uid).set(data, SetOptions(merge: true));
  }

  Future saveFCMToken() async {
    final User currentUser = FirebaseAuth.instance.currentUser;

    // Get the token for this device
    String fcmToken = await fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null && currentUser != null) {
      var tokens = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('tokens')
          .doc(fcmToken);

      await tokens.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    } else {
      print(
          'Error saving FCM token! {currentUser: $currentUser, fcmToken: $fcmToken}');
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

    return usersRoot.doc(uid).update(data);
  }

  Future<bool> updateUsername(String username) async {
    bool available = await checkUsernameAvailability(username);

    if (available) {
      print('New username (${locator<AuthService>().currentFirebaseUser.uid}): $username');
      usersRoot.doc(locator<AuthService>().currentFirebaseUser.uid).update({'username': username});
    } else {
      print('Username \'$username\' is already taken!');
    }

    return Future.value(available);
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final result = await usersRoot.where('username', isEqualTo: username).get();
    return result.docs.isEmpty;
  }

  Future updateUserPicURL(String picURL) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return await usersRoot.doc(currentUser.uid).update({'picURL': picURL});
    } else {
      return null;
    }
  }

  Future updateUserLocation(double lat, double lng) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print('Updating current user location in Firebase: [$lat, $lng]');
      return await usersRoot
          .doc(currentUser.uid)
          .update({'lat': lat, 'lng': lng});
    } else {
      print('Failed to update user location!');
      return null;
    }
  }

  Stream<List<MyUser>> membersData(String tribeID) {
    return tribesRoot.doc(tribeID).snapshots().map((tribeData) => tribeData
        .data()['members']
        .map((userID) => usersRoot
            .doc(userID)
            .snapshots()
            .map((userData) => MyUser.fromSnapshot(userData))
            .toList()));
  }

  Stream<List<MyUser>> get users {
    return usersRoot.snapshots().map((list) {
      return list.docs
          .map((userData) => MyUser.fromSnapshot(userData))
          .toList();
    });
  }

  Stream<List<Tribe>> get joinedTribes {
    return tribesRoot
        .where('members', arrayContains: locator<AuthService>().currentFirebaseUser.uid)
        .orderBy('created', descending: true)
        .snapshots()
        .map((list) {
      return list.docs.map((doc) => Tribe.fromSnapshot(doc)).toList();
    });
  }

  // Get not yet joined Tribes Stream
  Stream<List<Tribe>> get notYetJoinedTribes {
    return tribesRoot.snapshots().map((list) => list.docs
        .map((doc) => Tribe.fromSnapshot(doc))
        .where((tribe) => !tribe.members.contains(locator<AuthService>().currentFirebaseUser.uid))
        .toList());
  }

  // Get Posts Stream related to a specific Tribe
  // Return QuerySnapshot to make it work with FirebaseAnimatedList.
  Query posts(String tribeID) {
    // Chaining .where() and .orderBy() requires a Composite-index in Firebase Firestore setup.
    // See https://github.com/flutter/flutter/issues/15928#issuecomment-394197426 for more info.
    return postsRoot
        .where('tribeID', isEqualTo: tribeID)
        .orderBy('created', descending: true);
  }

  String get newPostId => postsRoot.doc().id;

  // Add a new Post
  Future addNewPost(
      {String postID,
      @required String title,
      @required String content,
      @required List<String> images,
      @required String tribeID}) async {
    DocumentReference postDoc = postsRoot.doc(postID ?? newPostId);
    Position currentPosition;

    var data = {
      'author': locator<AuthService>().currentFirebaseUser.uid,
      'title': title,
      'content': content,
      'tribeID': tribeID,
      'images': images,
      'likes': 1,
      'created': FieldValue.serverTimestamp(),
    };

    if (await Geolocator.isLocationServiceEnabled()) {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      data.putIfAbsent('lat', () => currentPosition.latitude);
      data.putIfAbsent('lng', () => currentPosition.longitude);
    }

    await usersRoot.doc(locator<AuthService>().currentFirebaseUser.uid).update({
      'createdPosts': FieldValue.arrayUnion([postDoc.id]),
      'likedPosts': FieldValue.arrayUnion([postDoc.id]),
    });

    print('Publishing post: $data');
    postDoc.set(data);

    return postDoc.id;
  }

  Future deletePost(Post post) {
    if (post.images.isNotEmpty) StorageService().deletePostImages(post.id);
    usersRoot.doc(post.author).update({
      'createdPosts': FieldValue.arrayRemove([post.id])
    });
    return postsRoot.doc(post.id).delete();
  }

  Future updatePostData(
      {@required String postID,
      String title,
      String content,
      List<String> images}) {
    Map<String, dynamic> data = {
      'updated': FieldValue.serverTimestamp(),
    };

    if (title != null) {
      data.putIfAbsent('title', () => title);
    }
    if (content != null) {
      data.putIfAbsent('content', () => content);
    }
    if (images != null) {
      data.putIfAbsent('images', () => images);
    }

    print('Updated Post data: $data');

    return postsRoot.doc(postID).update(data);
  }

  Stream<int> numberOfLikes(String postID) {
    return postsRoot
        .doc(postID)
        .get()
        .then((doc) => Post.fromSnapshot(doc).likes)
        .asStream();
  }

  Future createNewTribe(String userID, String name, String desc, String color,
      String imageURL, bool secret) {
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
    DocumentReference tribeDoc = tribesRoot.doc();

    // Create Chat Room
    FieldValue now = FieldValue.serverTimestamp();
    chatsRoot.doc(tribeDoc.id).set({
      'hasMessages': false,
      'updated': now,
      'created': now,
    }, SetOptions(merge: true));

    fcm.subscribeToTopic(tribeDoc.id);

    return tribeDoc.set(data);
  }

  Future updateTribeData(String id, String name, String desc, String color,
      String password, String imageURL, bool secret) {
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
    return tribesRoot.doc(id).update(data);
  }

  Future deleteTribe(String id) {
    return tribesRoot.doc(id).delete();
  }

  Stream<Tribe> tribe(String tribeID) {
    return tribesRoot
        .doc(tribeID)
        .snapshots()
        .map((doc) => Tribe.fromSnapshot(doc));
  }

  Stream<MyUser> get currentUserDataStream {
    return usersRoot.doc(locator<AuthService>().currentFirebaseUser.uid).snapshots().map((snapshot) {
      _currentUserData.value = MyUser.fromSnapshot(snapshot);
      return currentUserData;
    });
  }

  Stream<MyUser> userData(String uid) {
    return usersRoot
        .doc(uid)
        .snapshots()
        .map((snapshot) => MyUser.fromSnapshot(snapshot));
  }

  Future unlikePost(String userID, String postID) {
    usersRoot.doc(userID).update({
      'likedPosts': FieldValue.arrayRemove([postID])
    });
    return postsRoot.doc(postID).update({'likes': FieldValue.increment(-1)});
  }

  Future likePost(String userID, String postID) {
    usersRoot.doc(userID).update({
      'likedPosts': FieldValue.arrayUnion([postID])
    });
    return postsRoot.doc(postID).update({'likes': FieldValue.increment(1)});
  }

  Stream<Post> post(String userID, String postID) {
    return postsRoot.doc(postID).snapshots().map((postData) {
      if (!postData.exists) {
        usersRoot.doc(userID).update({
          'likedPosts': FieldValue.arrayRemove([postID])
        });
      }

      return Post.fromSnapshot(postData);
    });
  }

  Future addUserToTribe(String tribeID) {
    fcm.subscribeToTopic(tribeID);
    return tribesRoot.doc(tribeID).update({
      'members': FieldValue.arrayUnion([locator<AuthService>().currentFirebaseUser.uid])
    });
  }

  Future leaveTribe(String tribeID) {
    fcm.unsubscribeFromTopic(tribeID);
    return tribesRoot.doc(tribeID).update({
      'members': FieldValue.arrayRemove([locator<AuthService>().currentFirebaseUser.uid])
    });
  }

  Stream<Message> mostRecentMessage(String roomID) {
    return chatsRoot
        .doc(roomID)
        .collection('messages')
        .limit(1)
        .orderBy('created', descending: true)
        .snapshots()
        .map((list) => list.docs
            .map((messageDoc) => Message.fromSnapshot(messageDoc))
            .first);
  }

  Query fiveLatestMessages(String tribeID) {
    return chatsRoot
        .doc(tribeID)
        .collection('messages')
        .limit(5)
        .orderBy('created', descending: true);
  }

  Query allMessages(String roomID) {
    return chatsRoot
        .doc(roomID)
        .collection('messages')
        .orderBy('created', descending: true);
  }

  Query privateChatRooms(String userID) {
    return chatsRoot
        .where('members', arrayContains: userID)
        .where('hasMessages', isEqualTo: true)
        .orderBy('updated', descending: true);
  }

  Future<String> createNewPrivateChatRoom(
      String userID, String friendID) async {
    String roomID = userID.hashCode <= friendID.hashCode
        ? '$userID-$friendID'
        : '$friendID-$userID';

    bool roomAlreadyExists = false;
    await chatsRoot
        .doc(roomID)
        .get()
        .then((onValue) => roomAlreadyExists = onValue.exists);

    if (!roomAlreadyExists) {
      var data = {
        'members': [userID, friendID],
      };

      print('Creating new chat room data: $data');
      chatsRoot.doc(roomID).set(data);
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

    DocumentReference roomRef = chatsRoot.doc(roomID);
    DocumentReference messageRef = roomRef.collection('messages').doc();

    return FirebaseFirestore.instance.runTransaction((transaction) {
      return Future.value(transaction.set(messageRef, data));
    }).then(
      (transaction) {
        transaction.update(roomRef, {
          'hasMessages': true,
          'updated': FieldValue.serverTimestamp(),
        });
      },
    );
  }

  Future<List<Tribe>> joinedTribesFuture(String userID) async {
    return tribesRoot.where('members', arrayContains: userID).get().then(
        (list) => list.docs.map((doc) => Tribe.fromSnapshot(doc)).toList());
  }

  Future<List<MyUser>> friendsList(String userID) async {
    List<MyUser> _friends = [];
    List<String> _alreadyAddedFriendIDs = [];
    List<Tribe> _joinedTribes = await joinedTribesFuture(userID);

    for (final tribe in _joinedTribes) {
      print('Looking at tribe: ${tribe.name}');
      for (final memberID in tribe.members) {
        if (memberID != userID) {
          if (!_alreadyAddedFriendIDs.contains(memberID)) {
            print('Adding friend: $memberID');
            MyUser friend = await usersRoot
                .doc(memberID)
                .get()
                .then((doc) => MyUser.fromSnapshot(doc));
            _friends.add(friend);
            _alreadyAddedFriendIDs.add(memberID);
          }
        }
      }
    }

    print('friends: $_friends');
    return _friends;
  }

  Future<List<MyUser>> tribeMembersList(List<String> members) async {
    List<MyUser> membersList = [];

    for (String memberID in members) {
      await usersRoot
          .doc(memberID)
          .get()
          .then((doc) => membersList.add(MyUser.fromSnapshot(doc)));
    }

    return membersList;
  }

  Future<bool> doesUserExist(String uid) async {
    DocumentSnapshot userDoc = await usersRoot.doc(uid).get();
    return userDoc.exists;
  }

  Future<MyUser> getUserData(String uid) {
    return usersRoot.doc(uid).get().then((doc) => MyUser.fromSnapshot(doc));
  }
}
