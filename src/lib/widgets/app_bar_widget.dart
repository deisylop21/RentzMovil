import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../widgets/search_bar_widget.dart';
import '../theme/app_theme.dart';
import '../pages/profile_page.dart';
import '../pages/favorites_pages.dart';

PreferredSizeWidget buildAppBar(BuildContext context, AuthModel authModel, ValueChanged<String> onSearchChanged) {
  return AppBar(
    toolbarHeight: 65.0,
    automaticallyImplyLeading: false,
    leading: IconButton(
      icon: Icon(Icons.notifications, color: AppTheme.White),
      onPressed: () {
        // Definir la acción
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No tienes notificaciones nuevas.',
              style: TextStyle(color: AppTheme.White),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      },
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    title: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SearchBarWidget(onSearchChanged: onSearchChanged),
          ),
        ],
      ),
    ),
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
    actions: [
      _buildProfileButton(context, authModel),
    ],
    elevation: 0,
    scrolledUnderElevation: 2,
    shadowColor: AppTheme.darkTurquoise.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
    ),
  );
}

Future<void> _logout(BuildContext context) async {
  final authModel = Provider.of<AuthModel>(context, listen: false);
  authModel.logout();
}

Widget _buildProfileButton(BuildContext context, AuthModel authModel) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: GestureDetector(
      onTap: () {
        _showProfileMenu(context, authModel);
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.secondaryColor,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: AppTheme.accentColor.withOpacity(0.4),
          child: Text(
            authModel.user?.nombre?.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              color: AppTheme.White,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

void _showProfileMenu(BuildContext context, AuthModel authModel) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.lightTurquoise.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                authModel.user?.nombre?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(color: AppTheme.White),
              ),
            ),
            title: Text(
              authModel.user?.nombre ?? 'Usuario',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.text),
            ),
            subtitle: Text(
              authModel.user?.correo ?? '',
              style: TextStyle(color: AppTheme.grey),
            ),
          ),
          Divider(color: AppTheme.darkTurquoise),
          _buildMenuOption(
            icon: Icons.person_outline,
            title: 'Mi Perfil',
            onTap: () {
              if (authModel.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
          _buildMenuOption(
            icon: Icons.favorite_border,
            title: 'Favoritos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          _buildMenuOption(
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () {
              Navigator.pushNamed(context, '/settings'); // Navega a la página de configuración
            },
          ),
          _buildMenuOption(
            icon: Icons.exit_to_app,
            title: 'Cerrar Sesión',
            onTap: () {
              _logout(context);
              Navigator.pop(context);
            },
            isDestructive: true,
          ),
        ],
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );
}

Widget _buildMenuOption({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: isDestructive ? AppTheme.errorColor : AppTheme.text, // Usar AppTheme.text
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
  );
}