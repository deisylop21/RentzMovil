import 'package:flutter/material.dart';
import '../api/direccion_api.dart';
import '../models/direccion_model.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';

class EditarDireccionPage extends StatefulWidget {
  final Direccion direccion;

  EditarDireccionPage({required this.direccion});

  @override
  _EditarDireccionPageState createState() => _EditarDireccionPageState();
}

class _EditarDireccionPageState extends State<EditarDireccionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController calleController;
  late TextEditingController numeroExteriorController;
  late TextEditingController numeroInteriorController;
  late TextEditingController codigoPostalController;
  late TextEditingController coloniaController;
  late TextEditingController referenciaController;
  late TextEditingController numeroContactoController;
  bool direccionPrioritaria = false;

  @override
  void initState() {
    super.initState();
    calleController = TextEditingController(text: widget.direccion.calle);
    numeroExteriorController = TextEditingController(text: widget.direccion.numeroExterior);
    numeroInteriorController = TextEditingController(text: widget.direccion.numeroInterior ?? "");
    codigoPostalController = TextEditingController(text: widget.direccion.codigoPostal);
    coloniaController = TextEditingController(text: widget.direccion.colonia);
    referenciaController = TextEditingController(text: widget.direccion.referencia ?? "");
    numeroContactoController = TextEditingController(text: widget.direccion.numeroContacto);
    direccionPrioritaria = widget.direccion.direccionPrioritaria;
  }

  @override
  void dispose() {
    calleController.dispose();
    numeroExteriorController.dispose();
    numeroInteriorController.dispose();
    codigoPostalController.dispose();
    coloniaController.dispose();
    referenciaController.dispose();
    numeroContactoController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final nuevaDireccion = Direccion(
        id: widget.direccion.id,
        calle: calleController.text,
        numeroExterior: numeroExteriorController.text,
        numeroInterior: numeroInteriorController.text.isEmpty ? null : numeroInteriorController.text,
        codigoPostal: codigoPostalController.text,
        colonia: coloniaController.text,
        referencia: referenciaController.text.isEmpty ? null : referenciaController.text,
        numeroContacto: numeroContactoController.text,
        direccionPrioritaria: direccionPrioritaria,
      );

      await DireccionesApi().updateDireccion(authModel.token ?? "", widget.direccion.id!, nuevaDireccion);
      Navigator.pop(context, nuevaDireccion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Dirección")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: calleController,
                decoration: InputDecoration(labelText: "Calle"),
                validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              TextFormField(
                controller: numeroExteriorController,
                decoration: InputDecoration(labelText: "Número Exterior"),
                validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              TextFormField(
                controller: numeroInteriorController,
                decoration: InputDecoration(labelText: "Número Interior (Opcional)"),
              ),
              TextFormField(
                controller: codigoPostalController,
                decoration: InputDecoration(labelText: "Código Postal"),
                validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              TextFormField(
                controller: coloniaController,
                decoration: InputDecoration(labelText: "Colonia"),
                validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              TextFormField(
                controller: referenciaController,
                decoration: InputDecoration(labelText: "Referencia (Opcional)"),
              ),
              TextFormField(
                controller: numeroContactoController,
                decoration: InputDecoration(labelText: "Número de Contacto"),
                validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              SwitchListTile(
                title: Text("Dirección Prioritaria"),
                value: direccionPrioritaria,
                onChanged: (value) {
                  setState(() {
                    direccionPrioritaria = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCambios,
                child: Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
