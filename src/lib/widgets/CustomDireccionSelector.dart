import 'package:flutter/material.dart';
import '../models/direccion_model.dart';
import '../theme/app_theme.dart';

class CustomDireccionSelector extends StatelessWidget {
  final List<Direccion> direcciones;
  final Direccion? direccionSeleccionada;
  final Function(Direccion?) onDireccionChanged;
  final VoidCallback onAddDireccionPressed;

  const CustomDireccionSelector({
    Key? key,
    required this.direcciones,
    required this.direccionSeleccionada,
    required this.onDireccionChanged,
    required this.onAddDireccionPressed,
  }) : super(key: key);

  void _navigateToAddDireccion(BuildContext context) {
    Navigator.pushNamed(context, '/direcciones').then((_) {
      onAddDireccionPressed(); // Vuelve a cargar las direcciones después de agregar una nueva
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dirección de Entrega",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_location_alt),
                  onPressed: () => _navigateToAddDireccion(context),
                  tooltip: 'Agregar Nueva Dirección',
                  color: AppTheme.text,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (direcciones.isEmpty)
              _buildNoDireccionesWidget(context)
            else
              Column(
                children: [
                  DropdownButtonFormField<Direccion>(
                    value: direccionSeleccionada,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Selecciona una dirección",
                      filled: true,
                      fillColor: AppTheme.grey,
                    ),
                    onChanged: onDireccionChanged,
                    items: direcciones.map((direccion) {
                      return DropdownMenuItem(
                        value: direccion,
                        child: Text("${direccion.calle} #${direccion.numeroExterior}"),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/direcciones');
                      onAddDireccionPressed(); // Actualiza las direcciones después de agregar una nueva
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Agregar Nueva Dirección"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.text,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDireccionesWidget(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.location_off,
          size: 48,
          color: AppTheme.grey,
        ),
        const SizedBox(height: 8),
        const Text(
          "No hay direcciones registradas",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _navigateToAddDireccion(context),
          icon: const Icon(Icons.add_location),
          label: const Text("Agregar Dirección"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}