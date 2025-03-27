import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart'; // Importa el archivo donde están definidos los colores

class ThemeModel with ChangeNotifier {
  bool _isDarkMode = false; // Estado inicial: modo claro

  // Getter para saber si estamos en modo oscuro
  bool get isDarkMode => _isDarkMode;

  // Constructor
  ThemeModel() {
    _loadThemePreference();
  }

  // Método para alternar entre modo claro y oscuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    AppTheme.setDarkMode(_isDarkMode); // Actualiza el modo en AppTheme
    notifyListeners(); // Notifica a los widgets que el tema ha cambiado

    // Guardar la preferencia en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Cargar la preferencia de tema desde SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Si no existe, usa false como valor predeterminado
    AppTheme.setDarkMode(_isDarkMode); // Aplica el tema guardado al iniciar la app
    notifyListeners();
  }
}