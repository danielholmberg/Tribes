import 'package:cloud_firestore/cloud_firestore.dart';

class Tribe {
  final String id;
  final String name;
  final List<String> members;
  final int color;
  final int updated;

  Tribe({this.id, this.name, this.members, this.color, this.updated});

  factory Tribe.fromSnapshot(DocumentSnapshot doc) {
    return Tribe(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      members: List.from(doc.data['members'] ?? []),
      color: doc.data['color'] ?? 0xFF242424,
      updated: doc.data['updated'] ?? 0,
      /* members: doc.data['members']
        .map((snapshot) => User.fromSnapshot(snapshot)).toList(), */
    );
  }

  @override
  String toString() {
    return '[$id, $name, $color, $updated]';
  }
}
