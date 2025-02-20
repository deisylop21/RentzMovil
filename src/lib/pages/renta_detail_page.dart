import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/rentas_api.dart';
import '../models/renta_model.dart';
import '../models/auth_model.dart';

class RentaDetailPage extends StatefulWidget {
  final int idRenta;

  RentaDetailPage({required this.idRenta});

  @override
  _RentaDetailPageState createState() => _RentaDetailPageState();
}

class _RentaDetailPageState extends State<RentaDetailPage> {
  late Future<Renta> _rentaFuture;

  @override
  void initState() {
    super.initState();
    final authModel = Provider.of<AuthModel>(context, listen: false);
    _rentaFuture = RentasApi().fetchRentaById(authModel.token!, widget.idRenta);
  }

  Future<void> _realizarPago() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    try {
      String urlPago = await RentasApi().generarPago(authModel.token!, widget.idRenta);
      if (await canLaunch(urlPago)) {
        await launch(urlPago);
      } else {
        throw 'No se pudo abrir el enlace de pago';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la Renta')),
      body: FutureBuilder<Renta>(
        future: _rentaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No se encontró la renta"));
          } else {
            final renta = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      renta.urlImagenPrincipal,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported, size: 100),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(renta.nombreProducto, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Estado: ${renta.estado}", style: TextStyle(fontSize: 18)),
                  Text("Precio: \$${renta.precio}", style: TextStyle(fontSize: 18)),
                  Text("Total: \$${renta.total}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Text("Descripción", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(renta.descripcion),
                  SizedBox(height: 16),
                  Text("Dirección de entrega", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("${renta.calle} ${renta.numeroExterior}, ${renta.colonia}, CP: ${renta.codigoPostal}"),
                  Text("Referencia: ${renta.referencia}"),
                  Text("Contacto: ${renta.numeroContacto}"),
                  SizedBox(height: 16),
                  if (renta.estado == "Pendiente_Pago") // Solo muestra el botón si el estado es "Pendiente_Pago"
                    Center(
                      child: ElevatedButton(
                        onPressed: _realizarPago,
                        child: Text("Pagar ahora"),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}