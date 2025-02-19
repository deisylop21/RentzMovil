// lib/widgets/app_bar_widget.dart
import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../widgets/search_bar_widget.dart';

PreferredSizeWidget buildAppBar(BuildContext context, AuthModel authModel) {
  return AppBar(
    title: SearchBarWidget(), // Usamos el widget modular de la barra de búsqueda
    actions: [
      IconButton(
        icon: Icon(Icons.notifications, color: Colors.black),
        onPressed: () {},
      ),
    ],
    backgroundColor: Color(0xFFFF5733),
    elevation: 0,
  );
}