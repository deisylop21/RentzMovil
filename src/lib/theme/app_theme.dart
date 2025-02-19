// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.red;
  static const Color errorColor = Colors.red;
  static const Color backgroundColor = Colors.white;

  // Texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle priceStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
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

  // Tema global
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: titleStyle,
      ),
      textTheme: TextTheme(
        headlineMedium: titleStyle,
        bodyMedium: subtitleStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Cambio aquí
          textStyle: priceStyle,
        ),
      ),
    );
  }
}