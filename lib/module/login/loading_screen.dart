import 'package:flutter/material.dart';
import 'package:test_app/module/login/controller/auth_controller.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({Key? key}) : super(key: key);

  final AuthController authController = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: const Icon(Icons.home),
    );
  }
}
