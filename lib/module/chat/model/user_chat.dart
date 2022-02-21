import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/infra/constants/globals.dart';

class UserChat {
  final id;
  final photoUrl;
  final nickname;
  final aboutMe;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe});

  Map<String, String> toJson() {
    return {
      Globals.nickname: nickname,
      Globals.aboutMe: aboutMe,
      Globals.photoUrl: photoUrl,
    };
  }

  factory UserChat.fromJson(Map<String, Object?> json) {
    // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Object aboutMe = json[Globals.aboutMe] ?? '';
    Object photoUrl = json[Globals.photoUrl] ?? '';
    Object nickname = json[Globals.nickname] ?? '닉네임없음';

    return UserChat(
      id: json['id'],
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String aboutMe = data[Globals.aboutMe] ?? '';
    String photoUrl = data[Globals.photoUrl] ?? '';
    String nickname = data[Globals.nickname] ?? '닉네임없음';

    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }
}
