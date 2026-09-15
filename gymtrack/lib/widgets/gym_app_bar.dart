import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class GymAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;

  const GymAppBar({
    super.key,
    this.onNotificationPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF12181B),
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          tooltip: 'Menú principal',
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
          children: [
            TextSpan(
              text: 'GYM',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: 'TRACK',
              style: TextStyle(color: Color(0xFF00E676)),
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
              tooltip: 'Notificaciones',
              onPressed: onNotificationPressed ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No hay notificaciones pendientes'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

class GymDrawer extends StatelessWidget {
  final UserModel? user;

  const GymDrawer({super.key, this.user});

  void _handleLogout(BuildContext context) {
    AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? AuthService().currentUser;
    final gymName = currentUser?.gimnasio?.nombre ?? 'Mi Gimnasio';

    return Drawer(
      backgroundColor: const Color(0xFF141A1E),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF222D33), width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF00E676),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.fullName.isNotEmpty == true
                              ? currentUser!.fullName
                              : 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          gymName,
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUser?.email ?? '',
                          style: const TextStyle(
                            color: Color(0xFF7A8B94),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Opciones del Drawer
            ListTile(
              leading: const Icon(Icons.fitness_center_rounded, color: Color(0xFF00E676)),
              title: const Text('Gimnasio', style: TextStyle(color: Colors.white)),
              subtitle: Text(gymName, style: const TextStyle(color: Color(0xFF7A8B94), fontSize: 12)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white70),
              title: const Text('Configuración', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: Colors.white70),
              title: const Text('Ayuda y Soporte', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            const Divider(color: Color(0xFF222D33)),

            // Botón Cerrar Sesión
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
