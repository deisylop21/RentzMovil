import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

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
      onGenerateRoute: (settings) {
        print('Recibiendo ruta: ${settings.name}'); // Debug log

        if (settings.name != null) {
          try {
            final uri = Uri.parse(settings.name!);
            print('URI parseada: $uri'); // Debug log

            // Manejar tanto URLs completas como rutas internas
            if (uri.host == 'rentzmx.com') {
              // Es una URL completa de deep linking
              final pathSegments = uri.pathSegments;
              if (pathSegments.length >= 2 && pathSegments[0] == 'producto') {
                final productId = int.tryParse(pathSegments[1]);
                print('ID del producto encontrado (URL completa): $productId');

                if (productId != null) {
                  return MaterialPageRoute(
                    builder: (context) => ProductDetailPage(productId: productId),
                    settings: RouteSettings(
                      name: '/product-detail',
                      arguments: productId,
                    ),
                  );
                }
              }
            } else if (settings.name!.startsWith('/producto/')) {
              // Es una ruta interna
              final segments = uri.pathSegments;
              if (segments.length >= 2 && segments[0] == 'producto') {
                final productId = int.tryParse(segments[1]);
                print('ID del producto encontrado (ruta interna): $productId');

                if (productId != null) {
                  return MaterialPageRoute(
                    builder: (context) => ProductDetailPage(productId: productId),
                    settings: RouteSettings(
                      name: '/product-detail',
                      arguments: productId,
                    ),
                  );
                }
              }
            }
          } catch (e) {
            print('Error parseando URL: $e');
          }
        }

        // Rutas normales
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/cart':
            return MaterialPageRoute(builder: (_) => CartPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfilePage());
          case '/renta-form':
            return MaterialPageRoute(builder: (_) => RentaFormPage());
          case '/direcciones':
            return MaterialPageRoute(builder: (_) => DireccionesPage());
          case '/product-detail':
            final productId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: productId),
            );
          default:
            return MaterialPageRoute(builder: (_) => HomePage());
        }
      },
      routes: {}, // Vacío porque usamos onGenerateRoute
    );
  }
}