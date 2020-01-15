import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  final String id;
  final String userID;
  final String title;
  final String content;
  final String created;
  final List<String> attachments = new List<String>();

  Post({ this.id, this.userID, this.title, this.content, this.created });

  factory Post.fromSnapshot(DocumentSnapshot doc) {
    return Post(
        id: doc.documentID,
        userID: doc.data['userID'] ?? '',
        title: doc.data['title'] ?? '',
        content: doc.data['content'] ?? '',
        created: doc.data['created'] ?? '',
      );
  }

}