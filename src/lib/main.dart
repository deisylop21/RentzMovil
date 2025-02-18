// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home/HomePage.dart'; // Importa la pantalla de inicio desde la nueva ubicación

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentzMovil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Usa HomePage como la pantalla principal
    );
  }
}