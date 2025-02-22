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
      setState(() {
        _rentasFuture = Future.error("Debes iniciar sesión para ver tus rentas.");
      });
    } else {
      setState(() {
        _rentasFuture = RentasApi().fetchRentas(authModel.token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00988D), Color(0xFF2C6B74)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text(
              'Mis Rentas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF5C8),
              Color(0xFFF23E02).withOpacity(0.2),
            ],
          ),
        ),
        child: FutureBuilder<List<Renta>>(
          future: _rentasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00988D)),
                  strokeWidth: 6,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Card(
                  margin: EdgeInsets.all(20),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        SizedBox(height: 10),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadRentas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00988D),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Reintentar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_data.png', // Agrega una imagen aquí
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No tienes rentas registradas",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF013750),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final rentas = snapshot.data!;
              return ListView.builder(
                itemCount: rentas.length,
                itemBuilder: (context, index) {
                  final renta = rentas[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        renta.nombreProducto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF013750),
                        ),
                      ),
                      subtitle: Text(
                        "Estado: ${renta.estado} - Total: \$${renta.total}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C6B74),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF00988D),
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF00988D),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RentaDetailPage(idRenta: renta.idRentaProducto),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}