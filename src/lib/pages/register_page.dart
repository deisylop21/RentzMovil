import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importamos Provider
import '../api/auth_api.dart';
import '../models/auth_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApi _authApi = AuthApi();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false; // Controlador para mostrar/ocultar la contraseña

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Validaciones básicas
      if (_nombreController.text.isEmpty) {
        throw Exception("El nombre es obligatorio");
      }
      if (_correoController.text.isEmpty || !_correoController.text.contains('@')) {
        throw Exception("Ingresa un correo válido");
      }
      if (_passwordController.text.length < 6) {
        throw Exception("La contraseña debe tener al menos 6 caracteres");
      }
      // Preparamos los datos del usuario
      final Map<String, dynamic> userData = {
        "nombre": _nombreController.text.trim(),
        "apellidos": _apellidosController.text.trim(),
        "correo": _correoController.text.trim(),
        "numero_telefono": _telefonoController.text.trim(),
        "password": _passwordController.text.trim(),
      };
      // Enviamos los datos al backend
      await _authApi.register(userData);
      // Navegamos de vuelta a la pantalla de login
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
      backgroundColor: Color(0xFFFEF5C8), // Fondo claro
      appBar: AppBar(
        title: Text(
          "Registro",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF013750), // Azul oscuro
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png', // Ruta de tu logo
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),

              // Campo de nombre
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
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
              ),
              SizedBox(height: 16),

              // Campo de apellidos
              TextField(
                controller: _apellidosController,
                decoration: InputDecoration(
                  labelText: "Apellidos",
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
              ),
              SizedBox(height: 16),

              // Campo de correo electrónico
              TextField(
                controller: _correoController,
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

              // Campo de número de teléfono
              TextField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  labelText: "Número de Teléfono",
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
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              // Campo de contraseña con ícono de ojo
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Alternar visibilidad
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

              // Mensaje de error
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              SizedBox(height: 16),

              // Botón de registro (mejorado)
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF23E02), // Naranja vibrante
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Bordes redondeados pronunciados
                  ),
                  elevation: 5, // Sombra suave
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  "Registrarse",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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