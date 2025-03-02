import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importamos para usar inputFormatters
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
  String? _telefonoError; // Variable para almacenar el mensaje de error del teléfono
  bool _isPasswordVisible = false; // Controlador para mostrar/ocultar la contraseña
  bool _isPasswordFocused = false; // Controlador para detectar foco en el campo de contraseña
  final FocusNode _passwordFocusNode = FocusNode(); // FocusNode para el campo de contraseña

  // Validaciones en tiempo real para la contraseña
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en el foco del campo de contraseña
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose(); // Liberamos el FocusNode
    super.dispose();
  }

  // Función para actualizar las validaciones en tiempo real
  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(password);
    });
  }

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
      if (_telefonoController.text.length != 10) {
        throw Exception("El número de teléfono debe tener exactamente 10 dígitos.");
      }

      // Validación final de la contraseña
      if (!_hasMinLength ||
          !_hasUpperCase ||
          !_hasLowerCase ||
          !_hasNumber ||
          !_hasSpecialChar) {
        throw Exception(
          "La contraseña debe tener al menos 8 caracteres, una letra mayúscula, una letra minúscula, un número y un carácter especial (@\$!%*?&).",
        );
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
        _errorMessage = e.toString().replaceFirst("Exception: ", ""); // Eliminamos el prefijo "Exception"
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
                  errorText: _telefonoError, // Mostrar mensaje de error si existe
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo permite números
                  LengthLimitingTextInputFormatter(10), // Limita a 10 dígitos
                ],
                onChanged: (value) {
                  setState(() {
                    if (value.length != 10 && value.isNotEmpty) {
                      _telefonoError = "El número de teléfono debe tener exactamente 10 dígitos.";
                    } else {
                      _telefonoError = null;
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // Campo de contraseña con ícono de ojo
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode, // Asignamos el FocusNode
                obscureText: !_isPasswordVisible, // Alternar visibilidad
                onChanged: _validatePassword, // Validación en tiempo real
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
              SizedBox(height: 8),

              // Mostrar indicadores de validación solo si el campo de contraseña tiene el foco
              if (_isPasswordFocused)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildValidationRow(Icons.check_circle, "Al menos 8 caracteres", _hasMinLength),
                    _buildValidationRow(Icons.check_circle, "Una letra mayúscula", _hasUpperCase),
                    _buildValidationRow(Icons.check_circle, "Una letra minúscula", _hasLowerCase),
                    _buildValidationRow(Icons.check_circle, "Un número", _hasNumber),
                    _buildValidationRow(Icons.check_circle, "Un carácter especial (@\$!%*?&)", _hasSpecialChar),
                  ],
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
                  valueColor: AlwaysStoppedAnimation(Colors.white),
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

  // Función para construir filas de validación
  Widget _buildValidationRow(IconData icon, String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}