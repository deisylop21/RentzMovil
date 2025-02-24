import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importar intl para fechas
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/cart_page.dart';
import 'pages/product_detail_page.dart';
import 'models/auth_model.dart';
import 'theme/app_theme.dart';
import 'pages/profile_page.dart';
import 'pages/renta_form_page.dart';
import 'pages/direcciones_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegurar inicialización de widgets
  await initializeDateFormatting('es', null); // Cargar datos de localización

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
        '/renta-form': (context) => RentaFormPage(),
        '/direcciones': (context) => DireccionesPage(),
        '/product-detail': (context) => ProductDetailPage(
          productId: ModalRoute.of(context)!.settings.arguments as int,
        ),
      },
    );
  }
}
