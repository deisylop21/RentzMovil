import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DireccionesEmptyState extends StatelessWidget {
  final VoidCallback onAgregarPressed;

  const DireccionesEmptyState({
    Key? key,
    required this.onAgregarPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No tienes direcciones registradas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Agrega una nueva dirección para tus envíos",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAgregarPressed,
            icon: Icon(Icons.add_location_alt),
            label: Text("Agregar Dirección"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}