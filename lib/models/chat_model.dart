import 'package:cloud_firestore/cloud_firestore.dart';

class ChatData {
  final String id;
  final List<String> members;
  ChatData({
    this.id,
    this.members,
  });

  factory ChatData.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatData(
      id: doc.id,
      members: List.from(data['members'] ?? []),
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
