import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: BackButton(color: AppTheme.White),
        centerTitle: true,
        title: Text(
          "Iniciar Sesión",
          style: TextStyle(
            color: AppTheme.White,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),

              // Logo cuadrado mejorado
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.White,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: AppTheme.lightTurquoise,
                      child: Icon(
                        Icons.business,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32),

              Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "Ingresa tus credenciales para continuar",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkTurquoise,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // Campos de entrada mejorados
              Card(
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Campo de email mejorado
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.darkTurquoise),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.darkTurquoise.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.darkTurquoise, width: 2),
                          ),
                          filled: true,
                          fillColor: AppTheme.White,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (!_isValidEmail(value.trim()) && value.isNotEmpty) {
                              _errorMessage = "Por favor, ingresa un correo válido";
                            } else {
                              _errorMessage = null;
                            }
                          });
                        },
                      ),

                      SizedBox(height: 16),

                      // Campo de contraseña mejorado
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline, color: AppTheme.darkTurquoise),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppTheme.darkTurquoise,
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.darkTurquoise.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.darkTurquoise, width: 2),
                          ),
                          filled: true,
                          fillColor: AppTheme.White,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Olvidaste tu contraseña
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Navegación a recuperación de contraseña
                            Navigator.pushNamed(context, '/recovery');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.secondaryColor,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Mensaje de error mejorado
              if (_errorMessage != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkTurquoise,
                  foregroundColor: AppTheme.White,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.White),
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Sección de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes cuenta?",
                    style: TextStyle(
                      color: AppTheme.darkTurquoise,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      "Regístrate aquí",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}