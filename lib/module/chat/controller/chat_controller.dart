import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:test_app/infra/constants/collection.dart';
import 'package:test_app/infra/constants/globals.dart';
import 'package:test_app/module/chat/model/message_chat.dart';

class ChatController extends GetxController {
  static ChatController to = Get.find();

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  void sendMessage(String content, TypeMessage type, String groupChatId, String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(Collection.chatRoom)
        .doc(groupChatId)
        .collection(Collection.messages)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      typeMessage: type.name,
    );

    firebaseFirestore.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }

  /// 채팅 메세지 조회
  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(Collection.chatRoom)
        .doc(groupChatId)
        .collection(Collection.messages)
        .orderBy(Globals.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }
}
