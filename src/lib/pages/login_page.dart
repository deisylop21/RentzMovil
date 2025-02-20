import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importamos Provider
import '../api/auth_api.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApi _authApi = AuthApi();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Map<String, dynamic> result = await _authApi.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Guardamos el token y el usuario en el modelo global
      Provider.of<AuthModel>(context, listen: false).login(result['token'], result['user']);

      // Navegamos de vuelta a la pantalla Home
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
      // Cambiamos el color de fondo del Scaffold
      backgroundColor: Color(0xFFFEF5C8),
      appBar: AppBar(
        title: Text("Iniciar Sesión"),
        centerTitle: true,
        // Cambiamos el color de fondo del AppBar
        backgroundColor: Color(0xFF013750),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Correo Electrónico",
                labelStyle: TextStyle(
                  // Cambiamos el color del texto del label
                  color: Color(0xFF013750),
                ),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // Cambiamos el color del borde del TextField
                    color: Color(0xFF2C6B74),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // Cambiamos el color del borde del TextField cuando está enfocado
                    color: Color(0xFF00988D),
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Contraseña",
                labelStyle: TextStyle(
                  // Cambiamos el color del texto del label
                  color: Color(0xFF013750),
                ),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // Cambiamos el color del borde del TextField
                    color: Color(0xFF2C6B74),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // Cambiamos el color del borde del TextField cuando está enfocado
                    color: Color(0xFF00988D),
                  ),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                // Cambiamos el color del botón
                backgroundColor: Color(0xFF00988D),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                "Iniciar Sesión",
                style: TextStyle(
                  // Cambiamos el color del texto del botón
                  color: Color(0xFFFEF5C8),
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
                  // Cambiamos el color del texto del botón de texto
                  color: Color(0xFFF23E02),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}