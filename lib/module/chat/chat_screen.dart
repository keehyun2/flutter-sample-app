import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/infra/constants/app_themes.dart';
import 'package:test_app/infra/constants/globals.dart';
import 'package:test_app/module/chat/controller/chat_controller.dart';
import 'package:test_app/module/chat/controller/user_chat_controller.dart';
import 'package:test_app/module/chat/full_photo_screen.dart';
import 'package:test_app/module/chat/model/message_chat.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  final peerId = Get.arguments['peerId'];
  final peerAvatar = Get.arguments['peerAvatar'];
  final peerNickname = Get.arguments['peerNickname'];

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  ChatController chatController = ChatController.to;
  UserChatController userChatController = UserChatController.to;
  AuthController authController = AuthController.to;

  late final String currentUserId;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  final _limitIncrement = 20;
  String groupChatId = '';

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    currentUserId = authController.getUser!.uid;

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (currentUserId.compareTo(widget.peerId) > 0) {
      groupChatId = '$currentUserId-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$currentUserId';
    }

    userChatController.updateUserChat(
      currentUserId,
      {Globals.chattingWith: widget.peerId},
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatController.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, TypeMessage type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatController.sendMessage(content, type, groupChatId, currentUserId, widget.peerId);
      if(listScrollController.hasClients){
        listScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: AppThemes.greyColor);
    }
  }

  /// 상대방 메세지
  Widget getPeerMessage(MessageChat messageChat, bool isPeerMessageLast) {
    Widget avatar;
    Widget result;

    /// 상대방 아바타
    if (isPeerMessageLast) {
      avatar = Material(
        child: Image.network(
          widget.peerAvatar,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppThemes.themeColor,
                value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, object, stackTrace) {
            return const Icon(
              Icons.account_circle,
              size: 35,
              color: AppThemes.greyColor,
            );
          },
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(18),
        ),
        clipBehavior: Clip.hardEdge,
      );
    } else {
      avatar = Container(width: 35);
    }

    /// 메세지
    TypeMessage typeMessage = TypeMessage.values.byName(messageChat.typeMessage);
    switch (typeMessage) {
      case TypeMessage.text:
        result = Container(
          child: Text(
            messageChat.content,
            style: const TextStyle(color: Colors.white),
          ),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          width: 200,
          decoration: BoxDecoration(color: AppThemes.primaryColor, borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(left: 10),
        );
        break;
      case TypeMessage.image:
        result = Container(
          child: TextButton(
            child: Material(
              child: Image.network(
                messageChat.content,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppThemes.greyColor2,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    width: 200,
                    height: 200,
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
                errorBuilder: (context, object, stackTrace) => Material(
                  child: Image.asset(
                    'images/img_not_available.jpeg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPhotoScreen(url: messageChat.content),
                ),
              );
            },
            style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
          ),
          margin: const EdgeInsets.only(left: 10),
        );
        break;
      case TypeMessage.sticker:
        result = Container(
          child: Image.asset(
            'images/${messageChat.content}.gif',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          margin: EdgeInsets.only(bottom: isPeerMessageLast ? 20 : 10, right: 10),
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            avatar,
            result,
          ]),
        ],
      ),
    );
  }

  /// 메세지 타입(텍스트, 이미지, 스티커)에 따라서 위젯을 반환
  Widget getMyMessage(MessageChat messageChat) {
    Widget result;
    TypeMessage typeMessage = TypeMessage.values.byName(messageChat.typeMessage);

    switch (typeMessage) {
      case TypeMessage.text:
        result = Container(
          child: Text(
            messageChat.content,
            style: const TextStyle(color: AppThemes.primaryColor),
          ),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          width: 200,
          decoration: BoxDecoration(color: AppThemes.greyColor2, borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(bottom: 10, right: 10),
        );
        break;
      case TypeMessage.image:
        result = Container(
          child: OutlinedButton(
            child: Material(
              child: Image.network(
                messageChat.content,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppThemes.greyColor2,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    width: 200,
                    height: 200,
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
                  return Material(
                    child: Image.asset(
                      'images/img_not_available.jpeg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    clipBehavior: Clip.hardEdge,
                  );
                },
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPhotoScreen(
                    url: messageChat.content,
                  ),
                ),
              );
            },
            style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
          ),
          margin: const EdgeInsets.only(bottom: 10, right: 10),
        );
        break;
      case TypeMessage.sticker:
        result = Container(
          child: Image.asset(
            'images/${messageChat.content}.gif',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          margin: const EdgeInsets.only(bottom: 10, right: 10),
        );
        break;
    }

    return Align(
      child: result,
      alignment: Alignment.centerRight,
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      /// 내 메세지 여부
      bool isMine = messageChat.idFrom == currentUserId;
      /// 상대방 마지막 메세지 여부
      bool isPeerMessageLast = isLastMessageLeft(index);
      return isMine ? getMyMessage(messageChat) : getPeerMessage(messageChat, isPeerMessageLast);
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(Globals.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(Globals.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      userChatController.updateUserChat(
        currentUserId,
        {Globals.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.peerNickname,
          style: const TextStyle(color: AppThemes.primaryColor),
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),

                // Sticker
                // isShowSticker ? buildSticker() : const SizedBox.shrink(),

                // Input content
                buildInput(),
              ],
            ),

            // Loading
            // buildLoading()
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  // Widget buildLoading() {
  //   return Positioned(
  //     child: isLoading ? LoadingView() : const SizedBox.shrink(),
  //   );
  // }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: getImage,
                color: AppThemes.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.face),
                onPressed: getSticker,
                color: AppThemes.primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          Expanded(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              style: const TextStyle(color: AppThemes.primaryColor, fontSize: 15),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: AppThemes.greyColor),
              ),
              focusNode: focusNode,
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, TypeMessage.text),
                color: AppThemes.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppThemes.greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Expanded(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatController.getChatStream(groupChatId, _limit),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(child: Text('No message here yet...'));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppThemes.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppThemes.themeColor,
              ),
            ),
    );
  }
}
