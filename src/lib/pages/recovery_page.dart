import 'package:flutter/material.dart';
import '../api/recovery_api.dart';
import '../theme/app_theme.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({Key? key}) : super(key: key);

  @override
  _RecoveryPageState createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCodeRequested = false;
  bool _isPasswordObscured = true;

  void _solicitarRecuperacion() async {
    try {
      final response = await RecoveryApi.solicitarRecuperacion(_emailController.text);
      if (response['success']) {
        setState(() {
          _isCodeRequested = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al solicitar recuperación de cuenta'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _verificarCodigo() async {
    try {
      final response = await RecoveryApi.verificarCodigo(
        _emailController.text,
        _codeController.text,
        _passwordController.text,
      );
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar el código de recuperación'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Recuperar Cuenta',
          style: AppTheme.titleStyle.copyWith(color: AppTheme.White),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Recuperación de Cuenta',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 24,
                    color: AppTheme.titulob, //titulo
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _isCodeRequested
                      ? 'Ingresa el código de recuperación y tu nueva contraseña'
                      : 'Ingresa tu correo electrónico para recuperar tu cuenta',
                  style: AppTheme.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildEmailTextField(),
                if (_isCodeRequested) ...[
                  const SizedBox(height: 16),
                  _buildRecoveryCodeTextField(),
                  const SizedBox(height: 16),
                  _buildPasswordTextField(),
                ],
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        labelStyle: TextStyle(color: AppTheme.grey),
        prefixIcon: Icon(Icons.email, color: AppTheme.secondaryColor), //icono
        filled: true,
        fillColor: AppTheme.text5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
        ),
      ),
      style: TextStyle(color: AppTheme.text),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildRecoveryCodeTextField() {
    return TextField(
      controller: _codeController,
      decoration: InputDecoration(
        labelText: 'Código de recuperación',
        labelStyle: TextStyle(color: AppTheme.grey),
        prefixIcon: Icon(Icons.security, color: AppTheme.secondaryColor), //icono
        filled: true,
        fillColor: AppTheme.text5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
        ),
      ),
      style: TextStyle(color: AppTheme.text),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Nueva contraseña',
        labelStyle: TextStyle(color: AppTheme.grey),
        prefixIcon: Icon(Icons.lock, color: AppTheme.secondaryColor), //icono
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.secondaryColor, //icono
          ),
          onPressed: () {
            setState(() {
              _isPasswordObscured = !_isPasswordObscured;
            });
          },
        ),
        filled: true,
        fillColor: AppTheme.text5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
        ),
      ),
      style: TextStyle(color: AppTheme.text),
      obscureText: _isPasswordObscured,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isCodeRequested ? _verificarCodigo : _solicitarRecuperacion,
      style: AppTheme.primaryButtonStyle.copyWith(
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
      ),
      child: Text(
        _isCodeRequested ? 'Verificar Código' : 'Solicitar Recuperación',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.White,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}