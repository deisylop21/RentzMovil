import 'package:flutter/material.dart';

class AppTheme {
  static bool _isDarkMode = false;

  static void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
  }

  // Colores del tema claro
  static const Color primaryColorLight = Color(0xFF1A2B3C);   // Deeper blue, more professional
  static const Color secondaryColorLight = Color(0xFFE67E22); // Warmer orange, more engaging
  static const Color accentColorLight = Color(0xFF3498DB);    // Brighter blue, better contrast
  static const Color darkTurquoiseLight = Color(0xFF34495E);  // Slightly darker shade for depth
  static const Color lightTurquoiseLight = Color(0xFFF5F5F0); // Subtle blue tint for backgrounds
  static const Color errorColorLight = Color(0xFFE74C3C);     // Brighter red for better visibility
  static const Color backgroundColorLight = Color(0xFFF8F9FB); // Slight blue tint for warmth
  static const Color whiteLight = Color(0xFFFFFFFF);          // Pure white
  static const Color successColorLight = Color(0xFF2ECC71);   // Brighter green for better visibility
  static const Color blackLight = Color(0xFF2C3E50);          // Not pure black, but dark blue-gray
  static const Color greyLight = Color(0x75BDC3C7);           // Lighter gray with blue undertone
  static const Color textLight = Color(0xFF000000);

  // Colores del tema oscuro
  static const Color primaryColorDark = Color(0xFF1F2833);      // Dark blue-gray
  static const Color secondaryColorDark = Color(0xFFF39C12);    // Slightly darker orange, still visible
  static const Color accentColorDark = Color(0xFF3498DB);       // Same accent as light for brand consistency
  static const Color darkTurquoiseDark = Color(0xFF17202A);     // Nearly black with blue undertone
  static const Color lightTurquoiseDark = Color(0xFF1F2833);    // Dark blue as secondary background
  static const Color errorColorDark = Color(0xFFE74C3C);        // Same error color for consistency
  static const Color backgroundColorDark = Color(0xFF121920);   // Very dark blue-gray
  static const Color whiteDark = Color(0xFFECF0F1);             // Off-white for text
  static const Color successColorDark = Color(0xFF2ECC71);      // Same success color for consistency
  static const Color blackDark = Color(0xFF000000);             // True black for elements needing depth
  static const Color greyDark = Color(0x757F8C8D);              // Medium gray with slight blue tint
  static const Color textDark = Color(0xA1FFFFFF);

  // Colores dinámicos
  static Color get primaryColor => _isDarkMode ? primaryColorDark : primaryColorLight;
  static Color get secondaryColor => _isDarkMode ? secondaryColorDark : secondaryColorLight;
  static Color get accentColor => _isDarkMode ? accentColorDark : accentColorLight;
  static Color get darkTurquoise => _isDarkMode ? darkTurquoiseDark : darkTurquoiseLight;
  static Color get lightTurquoise => _isDarkMode ? lightTurquoiseDark : lightTurquoiseLight;
  static Color get errorColor => _isDarkMode ? errorColorDark : errorColorLight;
  static Color get backgroundColor => _isDarkMode ? backgroundColorDark : backgroundColorLight;
  static Color get White => _isDarkMode ? whiteDark : whiteLight;
  static Color get successColor => _isDarkMode ? successColorDark : successColorLight;
  static Color get black => _isDarkMode ? blackDark : blackLight;
  static Color get grey => _isDarkMode ? greyDark : greyLight;
  static Color get text => _isDarkMode ? textDark : textLight;
  static Color get text2 => _isDarkMode ? textDark : primaryColorLight;
  static Color get container => _isDarkMode ? backgroundColorDark : whiteLight;
  static Color get text4 => _isDarkMode ? greyDark : greyLight;
  static Color get icon => _isDarkMode ? primaryColorDark : primaryColorLight;
  static Color get text5 => _isDarkMode ? textDark : lightTurquoiseLight;
  static Color get card => _isDarkMode ? lightTurquoiseDark : whiteLight;

  // Estilos de texto dinámicos
  static TextStyle get titleStyle => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: text,
  );

  static TextStyle get subtitleStyle => TextStyle(
    fontSize: 16,
    color: grey,
  );

  static TextStyle get priceStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: accentColor,
  );

  static TextStyle get promotionalPriceStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: secondaryColor,
  );

  static TextStyle get oldPriceStyle => TextStyle(
    fontSize: 16,
    decoration: TextDecoration.lineThrough,
    color: grey,
  );

  // Estilos de botones
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}