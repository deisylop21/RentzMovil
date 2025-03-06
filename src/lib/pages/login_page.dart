import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart';
import '../services/notification_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApi _authApi = AuthApi();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      _fcmToken = await _notificationService.initNotifications();
      print('Token FCM inicializado: $_fcmToken'); // Debug
    } catch (e) {
      print('Error al inicializar notificaciones: $e');
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Por favor, complete todos los campos";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Realizar login
      final Map<String, dynamic> result = await _authApi.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Si no tenemos token FCM, intentamos obtenerlo nuevamente
      if (_fcmToken == null) {
        _fcmToken = await FirebaseMessaging.instance.getToken();
        print('Token FCM obtenido durante login: $_fcmToken'); // Debug
      }

      // 3. Registrar token FCM si está disponible
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        try {
          print('Intentando registrar token FCM: $_fcmToken'); // Debug
          await _authApi.registrarTokenFCM(result['token'], _fcmToken!);
          print('Token FCM registrado exitosamente'); // Debug
        } catch (e) {
          print('Error al registrar token FCM: $e');
          // No interrumpimos el flujo de login si falla el registro del token
        }
      } else {
        print('No se pudo obtener token FCM'); // Debug
      }

      // 4. Guardar sesión y navegar
      await Provider.of<AuthModel>(context, listen: false)
          .login(result['token'], result['user']);
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFEF5C8),
    appBar: AppBar(
    title: Text(
    "Iniciar Sesión",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    ),
    ),
    centerTitle: true,
    backgroundColor: Color(0xFF013750),
    elevation: 0,
    ),
    body: SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Image.asset(
    'assets/images/logo.png',
    width: 150,
    height: 150,
    ),
    SizedBox(height: 20),

    TextField(
    controller: _emailController,
    decoration: InputDecoration(
    labelText: "Correo Electrónico",
    labelStyle: TextStyle(color: Color(0xFF013750)),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF00988D)),
    borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF013750)),
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    keyboardType: TextInputType.emailAddress,
    ),
    SizedBox(height: 16),
      TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: "Contraseña",
          labelStyle: TextStyle(color: Color(0xFF013750)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00988D)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF013750)),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xFF00988D),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
      SizedBox(height: 16),

      if (_errorMessage != null)
        Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
      SizedBox(height: 16),

      ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00345E),
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Text(
          "Iniciar Sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 16),

      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: Text(
          "¿No tienes cuenta? Regístrate aquí",
          style: TextStyle(
            color: Color(0xFF00988D),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
    ),
    ),
    ),
    );
  }
}