import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import '../widgets/direccion_card.dart';
import '../widgets/empty_stated.dart';
import '../widgets/nueva_direccion_form.dart';
import '../theme/app_theme.dart';

class DireccionesPage extends StatefulWidget {
  @override
  _DireccionesPageState createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {
  late Future<List<Direccion>> futureDirecciones;

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  void _cargarDirecciones() {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    setState(() {
      futureDirecciones = DireccionesApi().fetchDirecciones(authModel.token ?? "");
    });
  }

  void _agregarDireccion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      builder: (context) => NuevaDireccionForm(
        onDireccionAgregada: _cargarDirecciones,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.darkTurquoise],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Mis Direcciones",
          style: TextStyle(
            color: AppTheme.White,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.White, AppTheme.White],
          ),
        ),
        child: FutureBuilder<List<Direccion>>(
          future: futureDirecciones,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return DireccionesEmptyState(onAgregarPressed: _agregarDireccion);
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return DireccionCard(
                  direccion: snapshot.data![index],
                  onDireccionEliminada: _cargarDirecciones,
                  onDireccionEditada: _cargarDirecciones,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarDireccion,
        child: Icon(Icons.add_location_alt, size: 24),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.White,
        elevation: 4,
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          SizedBox(height: 16),
          Text(
            "Error al cargar las direcciones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _cargarDirecciones,
            icon: Icon(Icons.refresh),
            label: Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.White,
            ),
          ),
        ],
      ),
    );
  }
}