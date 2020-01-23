import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class Tribe {
  final String id;
  final String name;
  final List<String> members;
  final String founder;
  final Color color;
  final bool hasImage;
  final int updated;
  final int created;

  Tribe(
      {this.id,
      this.name,
      this.members,
      this.founder,
      this.hasImage,
      this.color,
      this.updated,
      this.created});

  factory Tribe.fromSnapshot(DocumentSnapshot doc) {
    return Tribe(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      members: List.from(doc.data['members'] ?? []),
      founder: doc.data['founder'] ?? '',
      color: Color(int.parse('0x${doc.data['color'] ?? 'FF242424'}')),
      hasImage: doc.data['hasImage'] ?? false,
      updated: doc.data['updated'] ?? 0,
      created: doc.data['created'] ?? 0,
    );
  }

  @override
  String toString() {
    return '[$id, $name, $members, $founder, $color, $hasImage, $updated, $created]';
  }
}
