import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/cart_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/profile_page.dart';
import 'pages/renta_form_page.dart';
import 'pages/direcciones_page.dart';
import 'models/auth_model.dart';
import 'models/cart_model.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'pages/recovery_page.dart';
import 'models/theme_model.dart';
import 'pages/settings_page.dart';
import 'pages/pago_exitoso_page.dart';
import 'pages/pago_fallido_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensaje recibido en segundo plano:');
  print('ID: ${message.messageId}');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
  print('Datos: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios
  await initializeDateFormatting('es', null);
  await Firebase.initializeApp();

  // Configurar handler de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar servicio de notificaciones
  final notificationService = NotificationService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: MyApp(notificationService: notificationService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final NotificationService notificationService;

  const MyApp({Key? key, required this.notificationService}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inicializar notificaciones
      await widget.notificationService.initNotifications();

      // Configurar callback para navegación cuando se toca una notificación
      widget.notificationService.onNotificationTapped = (RemoteMessage message) {
        _handleNotificationTap(message);
      };
    } catch (e) {
      print('Error al inicializar la aplicación: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Manejar la navegación basada en los datos de la notificación
    try {
      if (message.data.containsKey('product_id')) {
        final productId = int.tryParse(message.data['product_id']);
        if (productId != null) {
          navigatorKey.currentState?.pushNamed(
            '/product-detail',
            arguments: productId,
          );
        }
      }
      // Añade más casos según necesites
    } catch (e) {
      print('Error al manejar tap en notificación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    authModel.loadSession();

    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Renta de Mobiliario',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppTheme.backgroundColor,
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              secondary: AppTheme.secondaryColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppTheme.primaryColor,
              titleTextStyle: TextStyle(color: AppTheme.White),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppTheme.backgroundColor,
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              secondary: AppTheme.secondaryColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppTheme.primaryColor,
              titleTextStyle: TextStyle(color: AppTheme.White),
            ),
          ),
          themeMode: themeModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: '/home',
          onGenerateRoute: (settings) {
            print('Recibiendo ruta: ${settings.name}');

            // Manejo especial para RentaFormPage
            if (settings.name == '/renta-form') {
              final args = settings.arguments;
              if (args is CartItem) {
                return MaterialPageRoute(
                  builder: (context) => RentaFormPage(cartItem: args),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: No se proporcionó un producto válido"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return CartPage();
                  },
                );
              }
            }

            // Manejo de deep linking y rutas dinámicas
            if (settings.name != null) {
              try {
                final uri = Uri.parse(settings.name!);
                print('URI parseada: $uri');

                if (uri.host == 'rentzmx.com') {
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
                  } else if (uri.path == '/pago-exitoso') {
                    return MaterialPageRoute(
                      builder: (_) => const PagoExitosoPage(),
                      settings: settings,
                    );
                  } else if (uri.path == '/pago-fallido') {
                    return MaterialPageRoute(
                      builder: (_) => const PagoFallidoPage(),
                      settings: settings,
                    );
                  }
                } else if (settings.name!.startsWith('/producto/')) {
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

            // Rutas normales con manejo de argumentos
            switch (settings.name) {
              case '/home':
                return MaterialPageRoute(
                  builder: (_) => HomePage(),
                  settings: settings,
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (_) => LoginPage(),
                  settings: settings,
                );
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => RegisterPage(),
                  settings: settings,
                );
              case '/cart':
                return MaterialPageRoute(
                  builder: (_) => CartPage(),
                  settings: settings,
                );
              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => ProfilePage(),
                  settings: settings,
                );
              case '/direcciones':
                return MaterialPageRoute(
                  builder: (_) => DireccionesPage(),
                  settings: settings,
                );
              case '/recovery':
                return MaterialPageRoute(
                  builder: (_) => RecoveryPage(),
                  settings: settings,
                );
              case '/pago-exitoso':
                return MaterialPageRoute(
                  builder: (_) => const PagoExitosoPage(),
                  settings: settings,
                );
              case '/pago-fallido':
                return MaterialPageRoute(
                  builder: (_) => const PagoFallidoPage(),
                  settings: settings,
                );
              case '/product-detail':
                if (settings.arguments is int) {
                  final productId = settings.arguments as int;
                  return MaterialPageRoute(
                    builder: (_) => ProductDetailPage(productId: productId),
                    settings: settings,
                  );
                } else {
                  return MaterialPageRoute(
                    builder: (_) {
                      ScaffoldMessenger.of(_).showSnackBar(
                        SnackBar(
                          content: Text("Error: ID de producto no válido"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return HomePage();
                    },
                  );
                }
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => SettingsPage(),
                  settings: settings,
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => HomePage(),
                  settings: settings,
                );
            }
          },
          routes: {},
        );
      },
    );
  }
}