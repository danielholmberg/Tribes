import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class Tribe {
  final String id;
  final String name;
  final String desc;
  final List<String> members;
  final String founder;
  final String password;
  final Color color;
  final String imageURL;
  final int updated;
  final int created;

  Tribe(
      {this.id,
      this.name,
      this.desc,
      this.members,
      this.founder,
      this.password,
      this.imageURL,
      this.color,
      this.updated,
      this.created});

  factory Tribe.fromSnapshot(DocumentSnapshot doc) {
    return Tribe(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      desc: doc.data['desc'] ?? '',
      members: List.from(doc.data['members'] ?? []),
      founder: doc.data['founder'] ?? '',
      password: doc.data['password'] ?? '',
      color: Color(int.parse('0x${doc.data['color'] ?? 'FF242424'}')),
      imageURL: doc.data['imageURL'] ?? 'tribe-placeholder.jpg',
      updated: doc.data['updated'] ?? 0,
      created: doc.data['created'] ?? 0,
    );
  }

  @override
  String toString() {
    return '[$id, $name, $desc, $members, $founder, $color, $imageURL, $updated, $created]';
  }
}
