import 'dart:io';
import 'package:flutter/material.dart';



class FullScreenImage extends StatelessWidget {
  final File imageFile;
  final String name;
  const FullScreenImage({Key? key, required this.imageFile, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: name,
            child: Image.file(imageFile),
          ),
        ),
      ),
    );
  }
}
