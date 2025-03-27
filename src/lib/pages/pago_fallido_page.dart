import 'package:flutter/material.dart';

class PagoFallidoPage extends StatelessWidget {
  const PagoFallidoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago Fallido'),
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Pago no procesado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'No pudimos completar tu transacción. Por favor intenta nuevamente.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Regresar al carrito para reintentar
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Reintentar pago'),
            ),
            TextButton(
              onPressed: () {
                // Navegar al home y limpiar el stack de navegación
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                        (route) => false
                );
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}