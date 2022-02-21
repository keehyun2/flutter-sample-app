import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:test_app/infra/constants/collection.dart';
import 'package:test_app/infra/constants/globals.dart';
import 'package:test_app/module/chat/model/message_chat.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  static ChatController to = Get.find();

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  /// 메세지 보내기
  void sendMessage(String content, TypeMessage type, String groupChatId, String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(Collection.messages)
        .doc(groupChatId)
        .collection(groupChatId)
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

  Future<void> sendPushMessage(String _token) async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  String constructFCMPayload(String? token) {
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        // 'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        // 'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  /// 채팅 메세지 조회
  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(Collection.messages)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(Globals.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }
}
