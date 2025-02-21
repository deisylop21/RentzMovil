import 'package:flutter/material.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/rentas_page.dart'; // Importa la página de rentas
import '../models/auth_model.dart';

Widget buildBottomNavigationBar(BuildContext context, AuthModel authModel) {
  return BottomNavigationBar(
    currentIndex: 0,
    onTap: (index) {
      if (index == 0) {
        // Acción para ir a la pantalla de inicio (ya estamos ahí)
      } else if (index == 1) {
        // Acción para ir a rentas
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RentasPage()),
        );
      } else if (index == 2) {
        // Acción para ir al carrito
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartPage()),
        );
      } else if (index == 3) {
        // Acción para ir al perfil
        if (authModel.isAuthenticated) {
          // Si está autenticado, navegar a la página de perfil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        } else {
          // Si no está autenticado, ir al login
          Navigator.pushNamed(context, '/login');
        }
      }
    },
    backgroundColor: Colors.blue, // Cambia el color de fondo
    selectedItemColor: Color(0xFF013750), // Color del ítem seleccionado
    unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Inicio",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_shipping), // Icono de un camión
        label: "Rentas",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: "Carrito",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: "Perfil",
      ),
    ],
  );
}