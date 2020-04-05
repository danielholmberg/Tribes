import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribes/shared/constants.dart' as Constants;

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
    String fallbackColor = Constants.primaryColor.value.toRadixString(16);
    return Tribe(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      desc: doc.data['desc'] ?? '',
      members: List.from(doc.data['members'] ?? []),
      founder: doc.data['founder'] ?? '',
      password: doc.data['password'] ?? '',
      color: Color(int.parse('0x${doc.data['color'] ?? fallbackColor}')),
      imageURL: doc.data['imageURL'] ?? 'tribe-placeholder.jpg',
      updated: doc.data['updated'] ?? 0,
      created: doc.data['created'] ?? 0,
    );
  }

  Tribe copyWith({
    String id,
    String name,
    String desc,
    List<String> members,
    String founder,
    String password,
    Color color,
    String imageURL,
    int updated,
    int created,
  }) {
    return Tribe(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      members: members ?? this.members,
      founder: founder ?? this.founder,
      password: password ?? this.password,
      color: color ?? this.color,
      imageURL: imageURL ?? this.imageURL,
      updated: updated ?? this.updated,
      created: created ?? this.created,
    );
  }

  @override
  String toString() {
    return '[$id, $name, $desc, $members, $founder, $color, $imageURL, $updated, $created]';
  }
}
