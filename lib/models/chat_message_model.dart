import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Message {
  final String id;
  final String message;
  final String senderID;
  final Timestamp created;

  Message({
    this.id,
    this.message,
    this.senderID,
    this.created,
  });

  factory Message.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var created = data['created'];

    // Convert int-timestamp values
    if(created.runtimeType == int) {
      created = Timestamp.fromMillisecondsSinceEpoch(created);
    }

    return Message(
      id: doc.id,
      message: data['message'] ?? '',
      senderID: data['senderID'] ?? '',
      created: created,
    );
  }

  String formattedTime() {
    return DateFormat('kk:mm').format(DateTime.parse(created.toDate().toString()));
  }
}
