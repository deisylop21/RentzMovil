import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  SearchBarWidget({required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.White,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TextFormField(
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppTheme.White,
            hintText: 'Buscar en Rentz',
            hintStyle: TextStyle(
              color: AppTheme.grey,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.grey,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
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