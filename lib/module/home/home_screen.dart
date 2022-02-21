import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_app/infra/components/avatar.dart';
import 'package:test_app/infra/components/form_vertical_spacing.dart';
import 'package:test_app/module/chat/user_chat_screen.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = AuthController.to;
  int _selectedIndex = 0;

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    List<Widget> _innerScreenList = <Widget>[_innerScreenHome(), _innerScreenMap(), _innerScreenChat(), _innerScreenMe()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Get.toNamed('/setting');
              }),
        ],
      ),
      body: _innerScreenList.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(.60),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Map',
              icon: Icon(Icons.map),
            ),
            BottomNavigationBarItem(
              label: 'chat',
              icon: Icon(Icons.chat),
            ),
            BottomNavigationBarItem(
              label: 'me',
              icon: Icon(Icons.account_circle),
            ),
          ]),
    );
  }

  /// 홈 화면
  Widget _innerScreenHome() {
    return Center(
      child: Text('HOME', style: Theme.of(context).textTheme.headline1),
    );
  }

  /// 샘플 지도화면
  Widget _innerScreenMap() {
    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.4975445, 127.023454),
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
        });
  }

  /// 채팅 화면
  Widget _innerScreenChat() {
    // return Center(
    //   child: Text('Chat', style: Theme.of(context).textTheme.headline3),
    // );
    return const UserChatScreen();
  }

  /// 내정보 화면
  Widget _innerScreenMe() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Avatar(photoUrl: authController.firebaseUser.value!.photoURL),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FormVerticalSpace(),
              Text(
                'uid: ${authController.firebaseUser.value!.uid}',
                style: const TextStyle(fontSize: 16),
              ),
              const FormVerticalSpace(),
              Text(
                'email: ${authController.firebaseUser.value?.email ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
              const FormVerticalSpace(),
              Text(
                'displayName: ${authController.firebaseUser.value?.displayName ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
              const FormVerticalSpace(),
              Text(
                'emailVerified: ${authController.firebaseUser.value?.emailVerified ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
              const FormVerticalSpace(),
              Text(
                'phoneNumber: ${authController.firebaseUser.value?.phoneNumber ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
