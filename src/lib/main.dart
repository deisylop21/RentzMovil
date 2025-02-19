// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importamos Provider
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'models/auth_model.dart';
import 'theme/app_theme.dart';
import 'pages/register_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()), // Proveemos el modelo global
      ],
      child: MyApp(), // Usamos MyApp como el widget principal
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
      title: 'Renta de Mobiliario',
      theme: AppTheme.getTheme(),
      initialRoute: '/home', // Iniciamos directamente en la pantalla Home
      routes: {
        '/home': (context) => HomePage(), // Pantalla principal
        '/login': (context) => LoginPage(), // Pantalla de login
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
