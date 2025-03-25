import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FechasCard extends StatelessWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFinal;
  final VoidCallback onSeleccionarFecha;
  final String Function(DateTime) formatearFecha;

  const FechasCard({
    Key? key,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.onSeleccionarFecha,
    required this.formatearFecha,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chair, color: AppTheme.text, size: 24),
                SizedBox(width: 8),
                Text(
                  "Fechas de Renta",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onSeleccionarFecha,
              icon: Icon(Icons.calendar_today, color: AppTheme.backgroundColor),
              label: fechaInicio == null
                  ? Text("Seleccionar Fecha de Inicio")
                  : Column(
                children: [
                  Text(
                    "Inicio: ${formatearFecha(fechaInicio!)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "Fin: ${formatearFecha(fechaFinal!)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}