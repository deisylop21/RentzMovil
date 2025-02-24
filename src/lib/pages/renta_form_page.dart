import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../models/renta2_model.dart';
import '../api/rentas_api.dart';
import '../api/direccion_api.dart'; // Importar API de direcciones
import '../models/direccion_model.dart'; // Importar modelo de direcciones

class RentaFormPage extends StatefulWidget {
  @override
  _RentaFormPageState createState() => _RentaFormPageState();
}

class _RentaFormPageState extends State<RentaFormPage> {
  late CartItem item;
  DateTime? fechaInicio;
  DateTime? fechaFinal;
  late double total;
  List<Direccion> direcciones = []; // Lista de direcciones
  Direccion? direccionSeleccionada; // Dirección seleccionada

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    item = ModalRoute.of(context)!.settings.arguments as CartItem;
    total = double.parse(item.total) + 50; // Total con costo de envío
    _cargarDirecciones();
  }

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  Future<void> _cargarDirecciones() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    List<Direccion> fetchedDirecciones = await DireccionesApi().fetchDirecciones(authModel.token!);

    setState(() {
      direcciones = fetchedDirecciones;

      if (direcciones.isNotEmpty) {
        direccionSeleccionada = direcciones.firstWhere(
              (dir) => dir.id == direccionSeleccionada?.id,
          orElse: () => direcciones[0], // Si no la encuentra, usa la primera
        );
      } else {
        direccionSeleccionada = null;
      }
    });
  }

  Future<void> _rentarProducto() async {
    if (fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona una fecha de inicio")),
      );
      return;
    }
    if (direccionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona una dirección")),
      );
      return;
    }

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final fechaFinal = fechaInicio!.add(Duration(days: 3)); // +3 días

    final renta = Renta2(
      idProducto: item.idProducto,
      idDireccion: direccionSeleccionada!.id!,
      fechaInicio: fechaInicio!.toIso8601String(),
      fechaFinal: fechaFinal.toIso8601String(),
      costoEnvio: 50,
      total: total,
    );

    try {
      await RentasApi().crearRenta(authModel.token!, renta);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Renta creada con éxito")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear la renta: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulario de Renta")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Producto: ${item.nombreProducto}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Descripción: ${item.descripcion}"),
            SizedBox(height: 10),
            Text("Costo total: \$${total.toStringAsFixed(2)}"),
            SizedBox(height: 20),

            // Selección de dirección
            DropdownButton<Direccion>(
              value: direccionSeleccionada,
              onChanged: (Direccion? nuevaDireccion) {
                setState(() {
                  direccionSeleccionada = nuevaDireccion;
                });
              },
              items: direcciones.map<DropdownMenuItem<Direccion>>((Direccion direccion) {
                return DropdownMenuItem<Direccion>(
                  value: direccion,
                  child: Text(direccion.calle + " #" + direccion.numeroExterior),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );

                if (pickedDate != null) {
                  setState(() {
                    fechaInicio = pickedDate;
                    fechaFinal = pickedDate.add(Duration(days: 3));
                  });
                }
              },
              child: Text(fechaInicio == null
                  ? "Seleccionar Fecha de Inicio"
                  : "Inicio: ${fechaInicio!.toLocal().toString().split(' ')[0]} \nFin: ${fechaFinal!.toLocal().toString().split(' ')[0]}"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _rentarProducto,
              child: Text("Confirmar Renta"),
            ),
          ],
        ),
      ),
    );
  }
}
