import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/rentas_api.dart';
import '../models/renta_model.dart';
import '../models/auth_model.dart';
import 'renta_detail_page.dart';

class RentasPage extends StatefulWidget {
  @override
  _RentasPageState createState() => _RentasPageState();
}

class _RentasPageState extends State<RentasPage> {
  late Future<List<Renta>> _rentasFuture;

  @override
  void initState() {
    super.initState();
    _loadRentas();
  }

  void _loadRentas() {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    if (authModel.token == null || authModel.token!.isEmpty) {
      // Si no hay token, mostrar error
      setState(() {
        _rentasFuture = Future.error("Debes iniciar sesión para ver tus rentas.");
      });
    } else {
      // Si hay token, cargar las rentas
      setState(() {
        _rentasFuture = RentasApi().fetchRentas(authModel.token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Rentas'),
      ),
      body: FutureBuilder<List<Renta>>(
        future: _rentasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadRentas,
                    child: Text("Reintentar"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No tienes rentas registradas"));
          } else {
            final rentas = snapshot.data!;
            return ListView.builder(
              itemCount: rentas.length,
              itemBuilder: (context, index) {
                final renta = rentas[index];
                return ListTile(
                  title: Text(renta.nombreProducto),
                  subtitle: Text("Estado: ${renta.estado} - Total: \$${renta.total}"),
                  leading: Icon(Icons.shopping_bag),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RentaDetailPage(idRenta: renta.idRentaProducto),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
