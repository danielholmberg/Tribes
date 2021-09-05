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
  final Timestamp created;
  final Timestamp updated;

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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var created = data['created'];
    var updated = data['updated'];

    // Convert int-timestamp values
    if(created.runtimeType == int) {
      created = Timestamp.fromMillisecondsSinceEpoch(created);
    }
    if(updated.runtimeType == int) {
      updated = Timestamp.fromMillisecondsSinceEpoch(updated);
    }

    return Post(
      id: doc.id,
      author: data['author'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      tribeID: data['tribeID'] ?? '',
      images: List.from(data['images'] ?? []),
      lat: data['lat'] ?? 0, // value 0 is used for fail-safe check for a location
      lng: data['lng'] ?? 0, // value 0 is used for fail-safe check for a location
      likes: data['likes'] ?? 0,
      created: created,
      updated: updated,
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
    Timestamp created,
    Timestamp updated,
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
