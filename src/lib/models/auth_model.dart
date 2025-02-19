// lib/models/auth_model.dart
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

  // Iniciar sesión
  Future<void> login(String token, User user) async {
    _token = token;
    _user = user;

    // Guardamos el token y el usuario en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(user.toJson()));

    notifyListeners();
  }

  // Cerrar sesión
  Future<void> logout() async {
    _token = null;
    _user = null;

    // Eliminamos el token y el usuario de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }

  // Cargar sesión desde SharedPreferences
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      _token = token;
      _user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }
}