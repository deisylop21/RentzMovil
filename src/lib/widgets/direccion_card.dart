import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/direccion_model.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import '../api/direccion_api.dart';
import '../pages/editar_direccion_page.dart';
import 'eliminar_direccion_dialog.dart';

class DireccionCard extends StatelessWidget {
  final Direccion direccion;
  final VoidCallback onDireccionEliminada;
  final VoidCallback onDireccionEditada;

  const DireccionCard({
    Key? key,
    required this.direccion,
    required this.onDireccionEliminada,
    required this.onDireccionEditada,
  }) : super(key: key);

  void _editarDireccion(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarDireccionPage(direccion: direccion),
      ),
    );
    if (result == true) {
      onDireccionEditada();
    }
  }

  void _eliminarDireccion(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => EliminarDireccionDialog(),
    );

    if (shouldDelete == true) {
      try {
        final authModel = Provider.of<AuthModel>(context, listen: false);
        await DireccionesApi().deleteDireccion(authModel.token ?? "", direccion.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dirección eliminada correctamente"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        onDireccionEliminada();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar la dirección: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Divider(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(),
        SizedBox(width: 16),
        Expanded(child: _buildDireccionInfo()),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.location_on,
        color: AppTheme.primaryColor,
        size: 24,
      ),
    );
  }

  Widget _buildDireccionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (direccion.direccionPrioritaria) _buildPrioritariaBadge(),
        Text(
          "${direccion.calle} #${direccion.numeroExterior}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (direccion.numeroInterior != null && direccion.numeroInterior!.isNotEmpty)
          Text(
            "Interior: ${direccion.numeroInterior}",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        SizedBox(height: 4),
        Text(
          direccion.colonia,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          "CP: ${direccion.codigoPostal}",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        if (direccion.referencia?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Referencia: ${direccion.referencia}",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Teléfono: ${direccion.numeroContacto}",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritariaBadge() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: AppTheme.secondaryColor),
          SizedBox(width: 4),
          Text(
            "Principal",
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _editarDireccion(context),
          icon: Icon(Icons.edit_outlined),
          label: Text("Editar"),
          style: TextButton.styleFrom(foregroundColor: AppTheme.accentColor),
        ),
        SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _eliminarDireccion(context),
          icon: Icon(Icons.delete_outline),
          label: Text("Eliminar"),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}