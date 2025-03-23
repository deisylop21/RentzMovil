import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthModel with ChangeNotifier {
  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;

  bool get isAuthenticated => _token != null && _user != null;

  // Iniciar sesión con validaciones
  Future<void> login(String? token, User? user) async {
    // Validación de parámetros
    if (token == null || token.isEmpty) {
      throw Exception('Token no puede ser nulo o vacío');
    }
    if (user == null) {
      throw Exception('Usuario no puede ser nulo');
    }

    try {
      _token = token;
      _user = user;

      // Guardamos el token y el usuario en SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Validación adicional antes de guardar
      final userJson = user.toJson();
      if (userJson.isEmpty) {
        throw Exception('Error al convertir usuario a JSON');
      }

      await prefs.setString('token', token);
      await prefs.setString('user', json.encode(userJson));

      notifyListeners();
    } catch (e) {
      // Limpiar estado en caso de error
      _token = null;
      _user = null;
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión con manejo de errores
  Future<void> logout() async {
    try {
      _token = null;
      _user = null;

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove('token'),
        prefs.remove('user'),
      ]);

      notifyListeners();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Cargar sesión desde SharedPreferences con validaciones
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token == null || token.isEmpty) {
        return; // No hay sesión guardada
      }

      if (userJson == null || userJson.isEmpty) {
        await logout(); // Limpiar sesión corrupta
        return;
      }

      try {
        final Map<String, dynamic> decodedUser = json.decode(userJson);
        final user = User.fromJson(decodedUser);

        // Validar que el usuario tenga los campos requeridos
        if (!_isValidUser(user)) {
          await logout();
          throw Exception('Datos de usuario inválidos');
        }

        _token = token;
        _user = user;
        notifyListeners();
      } catch (e) {
        await logout();
        throw Exception('Error al decodificar datos de usuario: $e');
      }
    } catch (e) {
      throw Exception('Error al cargar la sesión: $e');
    }
  }

  // Método auxiliar para validar usuario actualizado para coincidir con el modelo User
  bool _isValidUser(User user) {
    return user.nombre.isNotEmpty &&
        user.apellidos.isNotEmpty &&
        user.correo.isNotEmpty;
  }

  // Método para verificar si hay una sesión válida
  Future<bool> hasValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token == null || userJson == null) {
        return false;
      }

      // Intenta decodificar el usuario para verificar que los datos sean válidos
      try {
        final user = User.fromJson(json.decode(userJson));
        return _isValidUser(user);
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}