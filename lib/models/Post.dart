import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String author;
  final String title;
  final String content;
  final String fileURL;
  final String tribeID;
  final double lat;
  final double lng;
  final int likes;
  final int created;
  final int updated;

  Post(
      {this.id,
      this.author,
      this.title,
      this.content,
      this.fileURL,
      this.tribeID,
      this.lat,
      this.lng,
      this.likes,
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
      lat: doc.data['lat'] ?? 0, // value 0 is used for fail-safe check for a location
      lng: doc.data['lng'] ?? 0, // value 0 is used for fail-safe check for a location
      likes: doc.data['likes'] ?? 0,
      created: doc.data['created'] ?? 0,
      updated: doc.data['updated'] ?? 0,
    );
  }
}
