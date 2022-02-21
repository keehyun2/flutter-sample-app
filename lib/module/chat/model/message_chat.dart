import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/infra/constants/globals.dart';

class MessageChat {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  String typeMessage;

  MessageChat({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.typeMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      Globals.idFrom: idFrom,
      Globals.idTo: idTo,
      Globals.timestamp: timestamp,
      Globals.content: content,
      Globals.typeMessage: typeMessage,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    final idFrom = doc.get(Globals.idFrom);
    final idTo = doc.get(Globals.idTo);
    final timestamp = doc.get(Globals.timestamp);
    final content = doc.get(Globals.content);
    final typeMessage = doc.get(Globals.typeMessage);
    return MessageChat(idFrom: idFrom, idTo: idTo, timestamp: timestamp, content: content, typeMessage: typeMessage);
  }
}
