import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribes/models/Post.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // Users Collection Ref
  final CollectionReference usersCollection = Firestore.instance.collection('users');

  // Posts Collection Ref
  final CollectionReference postsCollection = Firestore.instance.collection('posts');


  Future updateUserData(String name, String username, String info) async {
    return await usersCollection.document(this.uid).setData({
      'name': name,
      'username': username,
      'info': info,
    });
  }

  // Post List from snapshot
  List<Post> _postListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Post(
        id: doc.documentID,
        userID: doc.data['userID'] ?? '',
        tribeID: doc.data['tribeID'] ?? '',
        title: doc.data['title'] ?? '',
        content: doc.data['content'] ?? '',
      );
    }).toList();
  }

  // Get Posts Stream
  Stream<List<Post>> get posts {
    return postsCollection.snapshots().map(_postListFromSnapshot);
  }

  // Add a new Post
  Future addNewPost(String tribeID, String title, String content) async {
    DocumentReference postRef = postsCollection.document();
    return await postsCollection.document(postRef.documentID).setData({
      'id': postRef.documentID,
      'userID': uid,
      'tribeID': tribeID,
      'title': title,
      'content': content,
    });
  }

}