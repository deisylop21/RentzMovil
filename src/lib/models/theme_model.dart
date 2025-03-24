import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Importa el archivo donde están definidos los colores

class ThemeModel with ChangeNotifier {
  bool _isDarkMode = false; // Estado inicial: modo claro

  // Getter para saber si estamos en modo oscuro
  bool get isDarkMode => _isDarkMode;

  // Método para alternar entre modo claro y oscuro
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    AppTheme.setDarkMode(_isDarkMode); // Actualiza el modo en AppTheme
    notifyListeners(); // Notifica a los widgets que el tema ha cambiado
  }
}