// lib/api/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthApi {
  // Singleton pattern
  static final AuthApi _instance = AuthApi._internal();
  factory AuthApi() => _instance;
  AuthApi._internal();

  final String baseUrl = "https://rentzmx.com/api/api/v1";

  // Función para login con soporte para FCM token
  Future<Map<String, dynamic>> login(String correo, String password, {String? fcmToken}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/cliente/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "correo": correo,
          "password": password,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        final authToken = responseData['token'];
        final user = User.fromJson(responseData['user']);

        // Registrar token FCM si está disponible
        if (fcmToken != null && fcmToken.isNotEmpty) {
          try {
            await registrarTokenFCM(authToken, fcmToken);
          } catch (e) {
            print('Warning: Error al registrar token FCM: $e');
            // No interrumpimos el login si falla el registro del token
          }
        }

        return {
          'token': authToken,
          'user': user,
        };
      } else {
        throw Exception(responseData['message'] ?? "Error al iniciar sesión");
      }
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Función para registro mejorada
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/cliente/register"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userData),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registro exitoso',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el registro',
          'error': response.statusCode
        };
      }
    } catch (e) {
      print('Error en registro: $e');
      return {
        'success': false,
        'message': 'Error en la conexión',
        'error': e.toString()
      };
    }
  }

  // Función mejorada para registrar token FCM
  Future<void> registrarTokenFCM(String authToken, String fcmToken) async {
    if (fcmToken.isEmpty) {
      throw Exception('Token FCM no puede estar vacío');
    }

    try {
      print('Registrando token FCM...');
      print('Token FCM (primeros 20 caracteres): ${fcmToken.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse("$baseUrl/notificacion/registrar-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken"
        },
        body: json.encode({
          "token_fcm": fcmToken,
          "platform": "flutter",
          "timestamp": DateTime.now().toUtc().toIso8601String(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('Token FCM registrado exitosamente');
      } else {
        print('Error al registrar token FCM: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        throw Exception(responseData['message'] ?? "Error al registrar token FCM");
      }
    } catch (e) {
      print('Error en registrarTokenFCM: $e');
      rethrow;
    }
  }

  // Función mejorada para obtener perfil
  Future<Profile> fetchProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/cliente/perfil"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Profile.fromJson(responseData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? "Error al cargar el perfil");
      }
    } catch (e) {
      print('Error en fetchProfile: $e');
      rethrow;
    }
  }

  // Función mejorada para actualizar perfil
  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/cliente/perfil"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(profileData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Perfil actualizado exitosamente',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al actualizar el perfil',
          'error': response.statusCode
        };
      }
    } catch (e) {
      print('Error en updateProfile: $e');
      return {
        'success': false,
        'message': 'Error en la conexión',
        'error': e.toString()
      };
    }
  }

  // Nuevo método para verificar estado del token FCM
  Future<bool> verificarTokenFCM(String authToken, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/notificacion/verificar-token"),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "token_fcm": fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['valid'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error al verificar token FCM: $e');
      return false;
    }
  }
}