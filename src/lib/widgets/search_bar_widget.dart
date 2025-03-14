import 'package:flutter/material.dart';
class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  SearchBarWidget({required this.onSearchChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: TextFormField(
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Buscar en Rentz',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.search_rounded,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
          ),
          onChanged: onSearchChanged,
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    );
  }
}