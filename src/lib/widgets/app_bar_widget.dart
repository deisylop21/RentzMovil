import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../widgets/search_bar_widget.dart';

PreferredSizeWidget buildAppBar(BuildContext context, AuthModel authModel, ValueChanged<String> onSearchChanged) {
  return AppBar(
    title: SearchBarWidget(onSearchChanged: onSearchChanged), // Usamos el widget modular de la barra de búsqueda
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