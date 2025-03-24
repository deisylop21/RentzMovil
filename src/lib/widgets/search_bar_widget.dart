import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchBarWidget({required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ocupa todo el ancho disponible
      margin: EdgeInsets.symmetric(vertical: 8), // Elimina el margen horizontal
      decoration: BoxDecoration(
        color: AppTheme.grey.withOpacity(0.2), // Fondo compatible con modo oscuro
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1), // Sombra sutil
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.text, // Texto adaptable a modo claro/oscuro
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.backgroundColor, // Fondo compatible con modo oscuro
                  hintText: 'Buscar en Rentz',
                  hintStyle: TextStyle(
                    color: AppTheme.grey, // Placeholder adaptable a modo claro/oscuro
                    fontSize: 16,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor, // Ícono adaptable a modo claro/oscuro
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
                      color: AppTheme.primaryColor, // Borde al enfocar
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}