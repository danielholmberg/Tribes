import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  final String id;
  final String author;
  final String title;
  final String content;
  final String tribeID;
  final int created;
  final List<String> attachments = new List<String>();

  Post({ this.id, this.author, this.title, this.content, this.tribeID, this.created });

  factory Post.fromSnapshot(DocumentSnapshot doc) {
    return Post(
        id: doc.documentID,
        author: doc.data['author'] ?? '',
        title: doc.data['title'] ?? '',
        content: doc.data['content'] ?? '',
        tribeID: doc.data['tribeID'] ?? '',
        created: doc.data['created'] ?? 0,
      );
  }

}
