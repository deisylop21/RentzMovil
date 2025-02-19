// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/cart_page.dart';
import 'pages/product_detail_page.dart'; // Importa la nueva página
import 'models/auth_model.dart';
import 'theme/app_theme.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    authModel.loadSession();

    return MaterialApp(
      title: 'Renta de Mobiliario',
      theme: AppTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/cart': (context) => CartPage(),
        '/profile': (context) => ProfilePage(),
        '/product-detail': (context) => ProductDetailPage(
          productId: ModalRoute.of(context)!.settings.arguments as int,
        ),
      },
    );
  }
}