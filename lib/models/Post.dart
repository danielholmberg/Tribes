import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String author;
  final String title;
  final String content;
  final String fileURL;
  final String tribeID;
  final int created;
  final int updated;
  final List<String> attachments = new List<String>();

  Post(
      {this.id,
      this.author,
      this.title,
      this.content,
      this.fileURL,
      this.tribeID,
      this.created,
      this.updated});

  factory Post.fromSnapshot(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      author: doc.data['author'] ?? '',
      title: doc.data['title'] ?? '',
      content: doc.data['content'] ?? '',
      tribeID: doc.data['tribeID'] ?? '',
      fileURL: doc.data['fileURL'] ?? '',
      created: doc.data['created'] ?? 0,
      updated: doc.data['updated'] ?? 0,
    );
  }
}
