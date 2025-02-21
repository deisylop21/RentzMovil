import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  SearchBarWidget({required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 36,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Buscar en Rentz',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.black),
          ),
          onChanged: onSearchChanged,
        ),
      ),
    );
  }
}