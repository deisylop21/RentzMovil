import 'package:flutter/material.dart';

class DireccionesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Direcciones"),
        centerTitle: true,
        backgroundColor: Color(0xFF013750),
      ),
      body: Center(
        child: Text(
          "Aquí se mostrarán las dies del usuario.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}