import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/renta_model.dart';

class RentasApi {
  final String baseUrl = 'https://darkred-donkey-427653.hostingersite.com/api/v1/rentas';

  Future<List<Renta>> fetchRentas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mis-rentas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> rentasJson = data['rentas'];
      return rentasJson.map((renta) => Renta.fromJson(renta)).toList();
    } else {
      throw Exception('Error al cargar las rentas');
    }
  }

  Future<Renta> fetchRentaById(String token, int idRenta) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$idRenta'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Renta.fromJson(data['renta']);
    } else {
      throw Exception('Error al cargar los detalles de la renta');
    }
  }
}
