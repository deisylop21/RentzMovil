import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favorite_model.dart';

class FavoriteApi {
  final String baseUrl = "https://rentzmx.com/api/api/v1";

  // Añadir a favoritos
  Future<Map<String, dynamic>> addToFavorite(String token, int idProducto) async {
    final response = await http.post(
      Uri.parse("$baseUrl/favoritos"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "id_producto": idProducto,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al añadir a favoritos: ${response.statusCode}");
    }
  }

  // Obtener favoritos
  Future<List<FavoriteProduct>> getFavorites(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/favoritos"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final favoritesResponse = FavoritesResponse.fromJson(responseData);
        return favoritesResponse.data;
      } else {
        throw Exception("Error al obtener favoritos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error en la solicitud: $e");
    }
  }

  // Eliminar de favoritos
  Future<Map<String, dynamic>> deleteFavorite(String token, int idFavorito) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/favoritos/$idFavorito"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Error al eliminar de favoritos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error en la solicitud: $e");
    }
  }
}