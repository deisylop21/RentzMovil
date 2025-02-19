// lib/api/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthApi {
  final String baseUrl = "https://darkred-donkey-427653.hostingersite.com/api/v1";

  // Función para login
  Future<Map<String, dynamic>> login(String correo, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/cliente/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "correo": correo,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success']) {
        return {
          'token': responseData['token'],
          'user': User.fromJson(responseData['user']),
        };
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception("Error al iniciar sesión: ${response.statusCode}");
    }
  }

  // Función para registro
  Future<void> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/cliente/register"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      // Registro exitoso
      return;
    } else if (response.statusCode == 400) {
      // Error específico (por ejemplo, correo ya registrado)
      final Map<String, dynamic> responseData = json.decode(response.body);
      throw Exception(responseData['message']);
    } else {
      // Otro error
      throw Exception("Error al registrar usuario: ${response.statusCode}");
    }
  }

  // Méodo para obtener el perfil del usuario
  Future<Profile> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/cliente/perfil"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Profile.fromJson(responseData['data']);
    } else {
      throw Exception("Error al cargar el perfil: ${response.statusCode}");
    }
  }

  // Méodo para actualizar el perfil del usuario
  Future<void> updateProfile(String token, Map<String, dynamic> profileData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/cliente/perfil"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(profileData),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar el perfil: ${response.statusCode}");
    }
  }
}