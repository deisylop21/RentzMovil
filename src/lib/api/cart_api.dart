import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_model.dart';

class CartApi {
  final String baseUrl = "https://darkred-donkey-427653.hostingersite.com/api/v1";

  // Obtener el carrito del usuario
  Future<List<CartItem>> fetchCart(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/carrito"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> cartItemsJson = responseData['data'];
      return cartItemsJson.map((json) => CartItem.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar el carrito: ${response.statusCode}");
    }
  }

  // Agregar producto al carrito
  Future<Map<String, dynamic>> addToCart(String token, int idProducto, int cantidad) async {
    final response = await http.post(
      Uri.parse("$baseUrl/carrito"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "id_producto": idProducto,
        "cantidad": cantidad,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al agregar al carrito: ${response.statusCode}");
    }
  }

  // Actualizar la cantidad de un producto en el carrito
  Future<void> updateCartItem(String token, int idCarrito, int cantidad) async {
    final response = await http.put(
      Uri.parse("$baseUrl/carrito"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "id_carrito": idCarrito,
        "cantidad": cantidad
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar el carrito: ${response.statusCode}");
    }
  }

  // Eliminar un producto del carrito
  Future<void> deleteCartItem(String token, int idCarrito) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/carrito/$idCarrito"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar el producto del carrito: ${response.statusCode}");
    }
  }
}