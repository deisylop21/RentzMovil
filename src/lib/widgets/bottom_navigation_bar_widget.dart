import 'package:flutter/material.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/rentas_page.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';

Widget buildBottomNavigationBar(BuildContext context, AuthModel authModel, {int currentIndex = 0}) {
  // Asegurarse de que currentIndex esté dentro del rango permitido
  if (currentIndex < 0 || currentIndex > 2) {
    currentIndex = 0;
  }

  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) {
      if (index == 0) {
        // Acción para ir a la pantalla de inicio
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (index == 1) {
        // Acción para ir a rentas
        if (currentIndex != 1) {  // Solo navegar si no estamos ya en rentas
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RentasPage()),
          );
        }
      } else if (index == 2) {
        // Acción para ir al carrito
        if (currentIndex != 2) {  // Solo navegar si no estamos ya en el carrito
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        }
      }
    },
    backgroundColor: AppTheme.lightTurquoise,
    selectedItemColor: AppTheme.text,
    unselectedItemColor: AppTheme.grey,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Inicio",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_shipping),
        label: "Rentas",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: "Carrito",
      ),
    ],
  );
}