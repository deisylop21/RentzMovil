import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart'; // Importa el ThemeModel

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferencias de Tema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.brightness_4_outlined),
              title: Text('Modo Oscuro'),
              trailing: Consumer<ThemeModel>(
                builder: (context, themeModel, child) {
                  return Switch(
                    value: themeModel.isDarkMode,
                    onChanged: (value) {
                      themeModel.toggleTheme();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}