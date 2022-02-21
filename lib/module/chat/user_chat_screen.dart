import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:test_app/infra/constants/app_themes.dart';
import 'package:test_app/infra/helpers/logger.dart';
import 'package:test_app/infra/helpers/time_late.dart';
import 'package:test_app/infra/helpers/utilities.dart';
import 'package:test_app/module/chat/controller/user_chat_controller.dart';
import 'package:test_app/module/chat/model/user_chat.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({Key? key}) : super(key: key);

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  UserChatController userChatController = UserChatController.to;
  AuthController authController = AuthController.to;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  String _textSearch = '';
  final _limitIncrement = 20;

  // bool isLoading = false;

  TimeLate timeLate = TimeLate(milliseconds: 300);
  TextEditingController searchBarTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    registerNotification(); // fcm 세팅
    configLocalNotification(); // local notification 세팅
    listScrollController.addListener(() {
      if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
        _limit += _limitIncrement;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings initializationSettingsIOS = const IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.d('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }
    });

    firebaseMessaging.getToken().then((token) {
      log.d('push token: $token');
      if (token != null) {
        userChatController.updateUserChat(authController.getUser!.uid, {'pushToken': token});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });

  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.keehyun2.test' : 'ios pakage name',
      'TEST APP',
      channelDescription: 'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    // print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSearchBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<UserChat>>(
            stream: userChatController.getUserChatSnapshot(authController.getUser!.uid, _limit, _textSearch),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.requireData;

              return ListView.builder(
                itemCount: data.size,
                itemBuilder: (context, index) => buildItem(context, data.docs[index].data()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: AppThemes.greyColor, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTec,
              onChanged: (value) {
                timeLate.run(() {
                  setState(() {
                    log.d('searchBarTec + $value');
                    _textSearch = value;
                  });
                });
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search nickname (you have to type exactly string)',
                hintStyle: TextStyle(fontSize: 13, color: AppThemes.greyColor),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          searchBarTec.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchBarTec.clear();
                    _textSearch = '';
                  },
                  child: const Icon(Icons.clear_rounded, color: AppThemes.greyColor, size: 20),
                )
              : const SizedBox.shrink()
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppThemes.greyColor2,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    );
  }

  Widget buildItem(BuildContext context, UserChat userChat) {
    final Widget leading;

    if (userChat.photoUrl.isNotEmpty) {
      leading = ClipOval(
        child: Image.network(
          userChat.photoUrl,
          fit: BoxFit.cover,
          width: 50,
          height: 50,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppThemes.themeColor,
                  value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, object, stackTrace) {
            return ClipOval(
              child: Image.asset(
                'assets/images/default.png',
                fit: BoxFit.cover,
                width: 50.0,
                height: 50.0,
              ),
            );
          },
        ),
      );
    } else {
      leading = ClipOval(
        child: Image.asset(
          'assets/images/default.png',
          fit: BoxFit.cover,
          width: 50.0,
          height: 50.0,
        ),
      );
    }

    final title = Text(
      'Nickname: ${userChat.nickname}',
      maxLines: 1,
      style: const TextStyle(color: AppThemes.primaryColor),
    );
    final subtitle = Text(
      'About me: ${userChat.aboutMe}',
      maxLines: 1,
      style: const TextStyle(color: AppThemes.primaryColor),
    );

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () {
        if (Utilities.isKeyboardShowing()) {
          Utilities.closeKeyboard(context);
        }
        Get.toNamed('/chat', arguments: {
          'peerId': userChat.id,
          'peerAvatar': userChat.photoUrl,
          'peerNickname': userChat.nickname,
        });
      },
    );
  }

}
