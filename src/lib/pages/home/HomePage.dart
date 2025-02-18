// lib/pages/home/HomePage.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RentzMovil - Home'),
      ),
      body: Center(
        child: Text('Bienvenido a RentzMovil'),
      ),
    );
  }
}