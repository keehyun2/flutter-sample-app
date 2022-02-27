import 'package:flutter/material.dart';
import 'package:test_app/infra/components/logo_graphic_header.dart';

class Avatar extends StatelessWidget {
  const Avatar({Key? key, this.photoUrl}) : super(key: key);
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null) {
      return Hero(
        tag: 'App Logo',
        child: CircleAvatar(
            radius: 70.0,
            child: ClipOval(
              child: Image.asset(
                'assets/images/default.png',
                fit: BoxFit.cover,
                width: 120.0,
                height: 120.0,
              ),
            )),
      );
    }else{
      return Hero(
        tag: 'User Avatar Image',
        child: CircleAvatar(
            radius: 70.0,
            child: ClipOval(
              child: Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                width: 120.0,
                height: 120.0,
              ),
            )),
      );
    }
  }
}
