import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E3B4E);    // Azul más profundo y elegante
  static const Color secondaryColor = Color(0xFFD4AF37);  // Dorado más sofisticado
  static const Color accentColor = Color(0xFF58B09C);    // Verde azulado más equilibrado
  static const Color darkTurquoise = Color(0xFF3E4A5C);   // Turquesa oscuro más sutil
  static const Color lightTurquoise = Color(0xFFF5F5F0);  // Turquesa claro más vibrante
  static const Color errorColor = Color(0xFFCB6D6D);     // Rojo Material 3 estándar
  static const Color backgroundColor = Color(0xFFFAFAFA); // Blanco cálido para mejor contraste
  static const Color White = Color(0xFFFFFFFF);
  static const Color successColor = Color(0xFF4CAF50);


  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF666666),
  );

  static const TextStyle priceStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: accentColor,
  );

  static const TextStyle promotionalPriceStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: secondaryColor,
  );

  static const TextStyle oldPriceStyle = TextStyle(
    fontSize: 16,
    decoration: TextDecoration.lineThrough,
    color: Colors.grey,
  );

  // Estilos de botones
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Tema global
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: backgroundColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),

      // Tema de AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: titleStyle.copyWith(color: Colors.white),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Tema de texto
      textTheme: TextTheme(
        headlineLarge: titleStyle,
        headlineMedium: titleStyle.copyWith(fontSize: 18),
        bodyLarge: subtitleStyle,
        bodyMedium: subtitleStyle.copyWith(fontSize: 14),
      ),

      // Tema de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),

      // Tema de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Tema de botones con contorno
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Tema de campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkTurquoise, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Tema de tarjetas
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Tema de iconos
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),
    );
  }
}