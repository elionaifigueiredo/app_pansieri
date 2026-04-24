import 'dart:io';
import 'package:flutter/material.dart';

class FotoFullPage extends StatelessWidget {
  final String foto;

  const FotoFullPage({super.key, required this.foto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: foto.startsWith('http')
              ? Image.network(foto)
              : Image.file(File(foto)),
        ),
      ),
    );
  }
}