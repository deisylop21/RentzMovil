import 'package:flutter/material.dart';
import '../api/recovery_api.dart';

class RecoveryPage extends StatefulWidget {
  @override
  _RecoveryPageState createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isCodeRequested = false;

  void _solicitarRecuperacion() async {
    try {
      final response = await RecoveryApi.solicitarRecuperacion(_emailController.text);
      if (response['success']) {
        setState(() {
          _isCodeRequested = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al solicitar recuperación de cuenta')),
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
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar el código de recuperación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            if (_isCodeRequested) ...[
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Código de recuperación'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Nueva contraseña'),
                obscureText: true,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCodeRequested ? _verificarCodigo : _solicitarRecuperacion,
              child: Text(_isCodeRequested ? 'Verificar Código' : 'Solicitar Recuperación'),
            ),
          ],
        ),
      ),
    );
  }
}