import 'package:flutter/material.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';

class DireccionesPage extends StatefulWidget {
  @override
  _DireccionesPageState createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {
  late Future<List<Direccion>> futureDirecciones;

  @override
  void initState() {
    super.initState();
    final authModel = Provider.of<AuthModel>(context, listen: false);
    futureDirecciones = DireccionesApi().fetchDirecciones(authModel.token ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis Direcciones")),
      body: FutureBuilder<List<Direccion>>(
        future: futureDirecciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay direcciones registradas"));
          }

          return ListView(
            children: snapshot.data!.map((direccion) {
              return ListTile(
                title: Text("${direccion.calle} #${direccion.numeroExterior}"),
                subtitle: Text("${direccion.colonia}, ${direccion.codigoPostal}"),
                trailing: direccion.direccionPrioritaria
                    ? Icon(Icons.star, color: Colors.amber)
                    : null,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
