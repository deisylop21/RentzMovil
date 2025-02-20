import 'package:flutter/material.dart';

class RentasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rentas'),
      ),
      body: Center(
        child: Text(
          'Esta es la página de rentas',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}