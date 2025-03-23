import 'dart:convert';
import 'package:http/http.dart' as http;

class RecoveryApi {
  static const String baseUrl = 'https://rentzmx.com/api/api/v1/cliente';

  static Future<Map<String, dynamic>> solicitarRecuperacion(String correo) async {
    final url = Uri.parse('$baseUrl/solicitar-recuperacion');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al solicitar recuperación de cuenta');
    }
  }

  static Future<Map<String, dynamic>> verificarCodigo(String correo, String codigo, String nuevaPassword) async {
    final url = Uri.parse('$baseUrl/verificar-codigo');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'codigo': codigo,
        'nuevaPassword': nuevaPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al verificar el código de recuperación');
    }
  }
}