import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/auth_model.dart';
import '../widgets/search_bar_widget.dart';
import '../theme/app_theme.dart';

PreferredSizeWidget buildAppBar(BuildContext context, AuthModel authModel, ValueChanged<String> onSearchChanged) {
  return AppBar(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    title: SearchBarWidget(onSearchChanged: onSearchChanged),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00345E),
            Color(0xFF00345E),
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
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
    ),
  );
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
            color: Colors.white,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white24,
          child: Text(
            authModel.user?.nombre?.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              color: Colors.white,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF00345E),
              child: Text(
                authModel.user?.nombre?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              authModel.user?.nombre ?? 'Usuario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(authModel.user?.correo ?? ''),
          ),
          Divider(),
          _buildMenuOption(
            icon: Icons.person_outline,
            title: 'Mi Perfil',
            onTap: () => Navigator.pop(context),
          ),
          _buildMenuOption(
            icon: Icons.favorite_border,
            title: 'Favoritos',
            onTap: () => Navigator.pop(context),
          ),
          _buildMenuOption(
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () => Navigator.pop(context),
          ),
          _buildMenuOption(
            icon: Icons.exit_to_app,
            title: 'Cerrar Sesión',
            onTap: () => Navigator.pop(context),
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
      color: isDestructive ? Colors.red : Color(0xFF043C87),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: isDestructive ? Colors.red : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
  );
}