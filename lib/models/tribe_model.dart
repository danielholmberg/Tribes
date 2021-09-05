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

  Tribe(
      {this.id,
      this.name,
      this.desc,
      this.members,
      this.founder,
      this.password,
      this.imageURL,
      this.color,
      this.secret,
      this.created,
      this.updated});

  factory Tribe.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String fallbackColor = Constants.primaryColor.value.toRadixString(16);
    var created = data['created'];
    var updated = data['updated'];

    // Convert int-timestamp values
    if (created.runtimeType == int) {
      created = Timestamp.fromMillisecondsSinceEpoch(created);
    }
    if (updated.runtimeType == int) {
      updated = Timestamp.fromMillisecondsSinceEpoch(updated);
    }

    return Tribe(
      id: doc.id,
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      members: List.from(data['members'] ?? []),
      founder: data['founder'] ?? '',
      password: data['password'] ?? '',
      color: Color(int.parse('0x${data['color'] ?? fallbackColor}')),
      imageURL: data['imageURL'] ?? 'tribe-placeholder.jpg',
      secret: data['secret'] ?? false,
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

class TribeRoomArguments {
  final String tribeId;
  final Color tribeColor;
  TribeRoomArguments({
    this.tribeId,
    this.tribeColor,
  });
}
