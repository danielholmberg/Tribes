import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String author;
  final String title;
  final String content;
  final List<String> images;
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
      this.images,
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
      images: List.from(doc.data['images'] ?? []),
      lat: doc.data['lat'] ?? 0, // value 0 is used for fail-safe check for a location
      lng: doc.data['lng'] ?? 0, // value 0 is used for fail-safe check for a location
      likes: doc.data['likes'] ?? 0,
      created: doc.data['created'] ?? 0,
      updated: doc.data['updated'] ?? 0,
    );
  }

  Post copyWith({
    String id,
    String author,
    String title,
    String content,
    List<String> images,
    String tribeID,
    double lat,
    double lng,
    int likes,
    int created,
    int updated,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      content: content ?? this.content,
      tribeID: tribeID ?? this.tribeID,
      images: images ?? this.images,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      likes: likes ?? this.likes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
