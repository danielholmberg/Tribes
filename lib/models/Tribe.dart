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
  final bool secret;
  final Timestamp created;
  final Timestamp updated;

  Tribe({
    this.id,
    this.name,
    this.desc,
    this.members,
    this.founder,
    this.password,
    this.imageURL,
    this.color,
    this.secret,
    this.created,
    this.updated
  });

  factory Tribe.fromSnapshot(DocumentSnapshot doc) {
    String fallbackColor = Constants.primaryColor.value.toRadixString(16);
    var created = doc.data['created'];
    var updated = doc.data['updated'];
    
    // Convert int-timestamp values
    if(created.runtimeType == int) {
      created = Timestamp.fromMillisecondsSinceEpoch(created);
    }
    if(updated.runtimeType == int) {
      updated = Timestamp.fromMillisecondsSinceEpoch(updated);
    }

    return Tribe(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      desc: doc.data['desc'] ?? '',
      members: List.from(doc.data['members'] ?? []),
      founder: doc.data['founder'] ?? '',
      password: doc.data['password'] ?? '',
      color: Color(int.parse('0x${doc.data['color'] ?? fallbackColor}')),
      imageURL: doc.data['imageURL'] ?? 'tribe-placeholder.jpg',
      secret: doc.data['secret'] ?? false,
      created: created,
      updated: updated,
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
    bool secret,
    Timestamp created,
    Timestamp updated,
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
      secret: secret ?? this.secret,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return '[$id, $name, $desc, $members, $founder, $color, $imageURL, $secret, $created, $updated]';
  }
}
