import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../models/renta2_model.dart';
import '../api/rentas_api.dart';

class RentaFormPage extends StatefulWidget {
  @override
  _RentaFormPageState createState() => _RentaFormPageState();
}

class _RentaFormPageState extends State<RentaFormPage> {
  late CartItem item;
  DateTime? fechaInicio;
  late double total;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    item = ModalRoute.of(context)!.settings.arguments as CartItem;
    total = double.parse(item.total) + 50; // Total con costo de envío
  }

  Future<void> _rentarProducto() async {
    if (fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona una fecha de inicio")),
      );
      return;
    }

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final fechaFinal = fechaInicio!.add(Duration(days: 2)); // +2 días

    final renta = Renta2(
      idProducto: item.idProducto,
      idDireccion: 1,
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
                  });
                }
              },
              child: Text(fechaInicio == null ? "Seleccionar Fecha de Inicio" : "Fecha: ${fechaInicio!.toLocal()}"),
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
