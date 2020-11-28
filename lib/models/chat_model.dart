import 'package:cloud_firestore/cloud_firestore.dart';

class ChatData {
  final String id;
  final List<String> members;
  ChatData({
    this.id,
    this.members,
  });

  factory ChatData.fromSnapshot(DocumentSnapshot doc) {
    return ChatData(
      id: doc.id,
      members: List.from(doc.data()['members'] ?? []),
    );
  }
}

class ChatRoomArguments {
  final String roomId;
  final List<String> members;
  final bool reply;
  ChatRoomArguments({
    this.roomId,
    this.members,
    this.reply,
  });
}
