import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String message;
  final String senderID;
  final int created;

  Message({
    this.id,
    this.message, 
    this.senderID, 
    this.created,
  });

  factory Message.fromSnapshot(DocumentSnapshot doc) {
    return Message(
      id: doc.documentID,
      message: doc.data['message'] ?? '',
      senderID: doc.data['senderID'] ?? '',
      created: doc.data['created'] ?? 0,
    );
  }
}