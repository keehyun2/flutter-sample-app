import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:test_app/infra/constants/app_themes.dart';

class FullPhotoScreen extends StatelessWidget {
  final String url;

  const FullPhotoScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Full Photo',
          style: TextStyle(color: AppThemes.primaryColor),
        ),
        centerTitle: true,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(url),
      ),
    );
  }
}
