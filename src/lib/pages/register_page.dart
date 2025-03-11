import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus nodes
  final FocusNode _nombreFocusNode = FocusNode();
  final FocusNode _apellidosFocusNode = FocusNode();
  final FocusNode _correoFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Services
  final AuthApi _authApi = AuthApi();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  String? _telefonoError;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordFocused = false;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
    _setupTextControllerListeners();
  }

  void _setupFocusListeners() {
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  void _setupTextControllerListeners() {
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(password);
      _passwordsMatch = password == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose focus nodes
    _nombreFocusNode.dispose();
    _apellidosFocusNode.dispose();
    _correoFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Field validations
      if (_nombreController.text.trim().isEmpty) {
        throw Exception("El nombre es obligatorio");
      }

      if (_apellidosController.text.trim().isEmpty) {
        throw Exception("Los apellidos son obligatorios");
      }

      final email = _correoController.text.trim();
      if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception("Por favor, ingresa un correo electrónico válido");
      }

      if (_telefonoController.text.length != 10) {
        throw Exception("El número de teléfono debe tener exactamente 10 dígitos");
      }

      // Password validations
      if (!_hasMinLength || !_hasUpperCase || !_hasLowerCase ||
          !_hasNumber || !_hasSpecialChar) {
        throw Exception(
            "La contraseña debe cumplir con todos los requisitos de seguridad"
        );
      }

      if (!_passwordsMatch) {
        throw Exception("Las contraseñas no coinciden");
      }

      // Prepare user data
      final Map<String, dynamic> userData = {
        "nombre": _nombreController.text.trim(),
        "apellidos": _apellidosController.text.trim(),
        "correo": email,
        "numero_telefono": _telefonoController.text.trim(),
        "password": _passwordController.text,
        "fecha_registro": DateTime.now().toUtc().toIso8601String(),
      };

      // Send registration request
      await _authApi.register(userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Registro exitoso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool? passwordVisible,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !(passwordVisible ?? false),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.secondaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon, color: AppTheme.secondaryColor),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            passwordVisible ?? false
                ? Icons.visibility
                : Icons.visibility_off,
            color: AppTheme.secondaryColor,
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.darkTurquoise],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Registro",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 24),
                _buildForm(),
                if (_errorMessage != null) _buildErrorMessage(),
                SizedBox(height: 24),
                _buildRegisterButton(),
                SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Hero(
      tag: 'logo',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Image.asset(
          'assets/images/logo.png',
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.account_circle,
                size: 64,
                color: AppTheme.secondaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(
            controller: _nombreController,
            label: "Nombre",
            icon: Icons.person,
            focusNode: _nombreFocusNode,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _apellidosController,
            label: "Apellidos",
            icon: Icons.person_outline,
            focusNode: _apellidosFocusNode,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _correoController,
            label: "Correo Electrónico",
            icon: Icons.email,
            focusNode: _correoFocusNode,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _telefonoController,
            label: "Número de Teléfono",
            icon: Icons.phone,
            focusNode: _telefonoFocusNode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          SizedBox(height: 16),
          _buildPasswordFields(),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _passwordController,
          label: "Contraseña",
          icon: Icons.lock,
          focusNode: _passwordFocusNode,
          isPassword: true,
          passwordVisible: _isPasswordVisible,
          onVisibilityToggle: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: "Confirmar Contraseña",
          icon: Icons.lock_outline,
          focusNode: _confirmPasswordFocusNode,
          isPassword: true,
          passwordVisible: _isConfirmPasswordVisible,
          onVisibilityToggle: () {
            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
          },
        ),
        if (_isPasswordFocused) _buildPasswordValidation(),
      ],
    );
  }

  Widget _buildPasswordValidation() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValidationRow(_hasMinLength, "Al menos 8 caracteres"),
          _buildValidationRow(_hasUpperCase, "Una letra mayúscula"),
          _buildValidationRow(_hasLowerCase, "Una letra minúscula"),
          _buildValidationRow(_hasNumber, "Un número"),
          _buildValidationRow(_hasSpecialChar, "Un carácter especial (@\$!%*?&)"),
          _buildValidationRow(_passwordsMatch, "Las contraseñas coinciden"),
        ],
      ),
    );
  }

  Widget _buildValidationRow(bool isValid, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
          children: [
          Icon(Icons.error_outline, color: Colors.red),
      SizedBox(width: 8),
      Expanded(
      child: Text(
      _errorMessage!,
      style: TextStyle(color: Colors.red[700], fontSize: 14),
    ),
        // Continuación del Widget _buildErrorMessage()
      ),
          ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
        ),
        child: _isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined),
            SizedBox(width: 8),
            Text(
              'Crear cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta?',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            foregroundColor: AppTheme.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Inicia sesión aquí',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}