import 'package:flutter/material.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({Key? key}) : super(key: key);

  final AuthController loginController = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('setting')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('language'),
            trailing: Text('개발중'),
          ),
          const ListTile(
            title: Text('theme'),
            trailing: Text('개발중'),
          ),
          ListTile(
            title: const Text('sign out'),
            trailing: ElevatedButton(
              child: const Text('sign out'),
              onPressed: () async {
                loginController.signOut();
              },
            ),
          )
        ],
      ),
    );
  }
}
