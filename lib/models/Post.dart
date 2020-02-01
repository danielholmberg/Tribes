import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Post {
  final String id;
  final String author;
  final String title;
  final String content;
  final String fileURL;
  final String tribeID;
  final double lat;
  final double lng;
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
      lat: doc.data['lat'] ?? Constants.initialLat,
      lng: doc.data['lng'] ?? Constants.initialLng,
      created: doc.data['created'] ?? 0,
      updated: doc.data['updated'] ?? 0,
    );
  }
}
