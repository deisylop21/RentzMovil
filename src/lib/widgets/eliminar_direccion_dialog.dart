import 'package:flutter/material.dart';

class EliminarDireccionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 28,
          ),
          SizedBox(width: 8),
          Text("Eliminar dirección"),
        ],
      ),
      content: Text(
        "¿Estás seguro de que deseas eliminar esta dirección? Esta acción no se puede deshacer.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            "Cancelar",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: Icon(Icons.delete_outline),
          label: Text("Eliminar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}