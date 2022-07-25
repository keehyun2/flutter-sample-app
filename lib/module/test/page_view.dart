import 'dart:typed_data';

import 'package:flutter/material.dart';

class PageViewTest extends StatelessWidget {
  const PageViewTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width;

    print('imageWidth $imageWidth');

    return Scaffold(
      body: Container(
        width: imageWidth,
        height: 230,
        color: Colors.white,
        child: PageView.builder(
          itemBuilder: (_, index) {
            return FadeInImage.memoryNetwork(
              key: key,
              image: 'https://dummyimage.com/360x230/ffffff/000000.png&text=360x230+dummy',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              placeholder: kTransparentImage,
            );
          },
        ),
      ),
    );
  }
}

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);