import 'package:flutter/material.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import 'editar_direccion_page.dart';

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

  void _editarDireccion(Direccion direccion) async {
    final nuevaDireccion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarDireccionPage(direccion: direccion)),
    );
    if (nuevaDireccion != null) {
      _cargarDirecciones();
    }
  }

  void _eliminarDireccion(int id) async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    await DireccionesApi().deleteDireccion(authModel.token ?? "", id);
    _cargarDirecciones();
  }

  void _agregarDireccion() {

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final token = authModel.token ?? "";

    print("🔑 Token enviado: $token");

    final _formKey = GlobalKey<FormState>();
    final _calleController = TextEditingController();
    final _numeroExteriorController = TextEditingController();
    final _numeroInteriorController = TextEditingController();
    final _codigoPostalController = TextEditingController();
    final _coloniaController = TextEditingController();
    final _referenciaController = TextEditingController();
    final _numeroContactoController = TextEditingController();
    bool _direccionPrioritaria = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Agregar Nueva Dirección"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _calleController,
                    decoration: InputDecoration(labelText: "Calle"),
                    validator: (value) => value!.isEmpty ? "Ingrese la calle" : null,
                  ),
                  TextFormField(
                    controller: _numeroExteriorController,
                    decoration: InputDecoration(labelText: "Número Exterior"),
                    validator: (value) => value!.isEmpty ? "Ingrese el número exterior" : null,
                  ),
                  TextFormField(
                    controller: _numeroInteriorController,
                    decoration: InputDecoration(labelText: "Número Interior (Opcional)"),
                  ),
                  TextFormField(
                    controller: _codigoPostalController,
                    decoration: InputDecoration(labelText: "Código Postal"),
                    validator: (value) => value!.isEmpty ? "Ingrese el código postal" : null,
                  ),
                  TextFormField(
                    controller: _coloniaController,
                    decoration: InputDecoration(labelText: "Colonia"),
                    validator: (value) => value!.isEmpty ? "Ingrese la colonia" : null,
                  ),
                  TextFormField(
                    controller: _referenciaController,
                    decoration: InputDecoration(labelText: "Referencia (Opcional)"),
                  ),
                  TextFormField(
                    controller: _numeroContactoController,
                    decoration: InputDecoration(labelText: "Número de Contacto"),
                    validator: (value) => value!.isEmpty ? "Ingrese el número de contacto" : null,
                  ),
                  SwitchListTile(
                    title: Text("Dirección Prioritaria"),
                    value: _direccionPrioritaria,
                    onChanged: (value) {
                      _direccionPrioritaria = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Guardar"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final nuevaDireccion = Direccion(
                    calle: _calleController.text,
                    numeroExterior: _numeroExteriorController.text,
                    numeroInterior: _numeroInteriorController.text.isNotEmpty
                        ? _numeroInteriorController.text
                        : null,
                    codigoPostal: _codigoPostalController.text,
                    colonia: _coloniaController.text,
                    referencia: _referenciaController.text.isNotEmpty
                        ? _referenciaController.text
                        : null,
                    numeroContacto: _numeroContactoController.text,
                    direccionPrioritaria: _direccionPrioritaria,
                  );

                  final authModel = Provider.of<AuthModel>(context, listen: false);
                  await DireccionesApi().addDireccion(authModel.token ?? "", nuevaDireccion);

                  Navigator.pop(context);
                  _cargarDirecciones();
                }
              },
            ),
          ],
        );
      },
    );
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editarDireccion(direccion),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarDireccion(direccion.id!),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarDireccion,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
