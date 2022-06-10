import 'dart:async';

import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:test_app/module/chat/chat_screen.dart';
import 'package:test_app/module/chat/controller/chat_controller.dart';
import 'package:test_app/module/chat/controller/user_chat_controller.dart';
import 'package:test_app/module/home/home_screen.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';
import 'package:test_app/module/login/loading_screen.dart';
import 'package:test_app/module/login/login_screen.dart';
import 'package:test_app/module/map/map_screen.dart';
import 'package:test_app/module/setting/setting_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded(() {
    runApp(const MyApp());
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/setting', page: () => SettingScreen()),
        GetPage(name: '/map', page: () => const MapScreen()),
        GetPage(name: '/loading', page: () => LoadingScreen()),
        GetPage(name: '/chat', page: () => ChatScreen()),
        // GetPage(name: '/userChat', page: () => const UserChatScreen()),
      ],
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<UserChatController>(() => UserChatController());
        Get.lazyPut<ChatController>(() => ChatController());
      }),
      initialRoute: '/loading',
    );
  }
}
