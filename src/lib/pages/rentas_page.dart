import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/rentas_api.dart';
import '../models/renta_model.dart';
import '../models/auth_model.dart';
import '../theme/app_theme.dart';
import 'renta_detail_page.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

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
        _rentasFuture =
            Future.error("Debes iniciar sesión para ver tus rentas.");
      });
    } else {
      setState(() {
        _rentasFuture = RentasApi().fetchRentas(authModel.token!);
      });
    }
  }

  Widget _buildRentaCard(Renta renta) {
    double totalAsDouble = double.tryParse(renta.total) ?? 0.0;


    // Imprimir la URL en consola
    print("Cargando imagen: ${renta.urlImagenPrincipal}");

    // Validar si la URL no está vacía y comienza con http/https
    bool isValidUrl = renta.urlImagenPrincipal.isNotEmpty &&
        (renta.urlImagenPrincipal.startsWith("http://") ||
            renta.urlImagenPrincipal.startsWith("https://"));

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RentaDetailPage(idRenta: renta.idRentaProducto),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar imagen del producto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: renta.urlImagenPrincipal.isNotEmpty
                        ? Image.network(
                      renta.urlImagenPrincipal,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported, size: 80,
                              color: AppTheme.grey),
                    )
                        : Icon(Icons.image, size: 80, color: AppTheme.grey),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          renta.nombreProducto,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Estado: ${renta.estado}",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.grey,
                    ),
                  ),
                  Text(
                    "\$${totalAsDouble.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.White,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.grey,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRentas,
              icon: Icon(Icons.refresh),
              label: Text("Reintentar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.White,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No tienes rentas registradas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Tus rentas aparecerán aquí",
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
            icon: Icon(Icons.add_shopping_cart),
            label: Text("Explorar productos"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: AppTheme.White,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Mis Rentas',
          style: TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRentas,
            color: AppTheme.White,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: FutureBuilder<List<Renta>>(
          future: _rentasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor),
                ),
              );
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            } else {
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildRentaCard(snapshot.data![index]);
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
          context,
          Provider.of<AuthModel>(context),
          currentIndex: 1 // 1 es el índice para la página de rentas
      ),
    );
  }
}