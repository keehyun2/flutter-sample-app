import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/infra/constants/collection.dart';
import 'package:test_app/infra/constants/globals.dart';
import 'package:test_app/infra/helpers/logger.dart';
import 'package:test_app/module/chat/model/user_chat.dart';

class UserChatController extends GetxController {
  static UserChatController to = Get.find();

  final userChatRef = FirebaseFirestore.instance.collection(Collection.users).withConverter<UserChat>(
        fromFirestore: (snapshots, _) => UserChat.fromJson(snapshots.data()!),
        toFirestore: (userChat, _) => userChat.toJson(),
      );

  /// userChat 업데이트
  void updateUserChat(String path, Map<String, dynamic> dataNeedUpdate) {
    userChatRef.doc(path).update(dataNeedUpdate);
  }

  /// userChat 목록 조회
  Stream<List<UserChat>> getUserChatStream(String myId, int limit, String? textSearch) {
    log.d('my uid : $myId, textSearch : $textSearch');
    Query<UserChat> query = userChatRef.where(Globals.id, isNotEqualTo: myId);
    if (textSearch != null && textSearch.isNotEmpty) { // 검색어가 있을때만 조건 추가
      query = query.where(Globals.nickname, isEqualTo: textSearch);
    }
    return query.limit(limit).snapshots().map((qShot) => qShot.docs.map((doc) => doc.data()).toList());
  }

  Stream<QuerySnapshot<UserChat>> getUserChatSnapshot(String myId, int limit, String? textSearch) {
    log.d('my uid : $myId, textSearch : $textSearch');
    Query<UserChat> query = userChatRef.limit(limit).where(Globals.id, isNotEqualTo: myId);
    if (textSearch != null && textSearch.isNotEmpty) { // 검색어가 있을때만 조건 추가
      query = query.where(Globals.nickname, isEqualTo: textSearch);
    }
    return query.snapshots();
  }

}
