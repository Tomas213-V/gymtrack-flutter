import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_socio_screen.dart';
import 'perfil_socio_screen.dart';
import 'videos/videos_socio_screen.dart';

class MasSocioScreen extends StatelessWidget {
  final Function(int index)? onNavigateToTab;

  const MasSocioScreen({
    super.key,
    this.onNavigateToTab,
  });

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que deseas salir de tu cuenta de socio?',
          style: TextStyle(color: Color(0xFFCCCCCC)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginSocioScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Más',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // 1. Mi perfil
            _buildMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Mi perfil',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PerfilSocioScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 2. Mi membresía
            _buildMenuItem(
              icon: Icons.credit_card_rounded,
              title: 'Mi membresía',
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(3);
                }
              },
            ),
            const SizedBox(height: 10),

            // 3. Mis pagos
            _buildMenuItem(
              icon: Icons.attach_money_rounded,
              title: 'Mis pagos',
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(3);
                }
              },
            ),
            const SizedBox(height: 10),

            // 4. Mis rutinas
            _buildMenuItem(
              icon: Icons.fitness_center_rounded,
              title: 'Mis rutinas',
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(1);
                }
              },
            ),
            const SizedBox(height: 10),

            // 5. Mi progreso
            _buildMenuItem(
              icon: Icons.show_chart_rounded,
              title: 'Mi progreso',
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(2);
                }
              },
            ),
            const SizedBox(height: 10),

            // 6. Videos de técnica
            _buildMenuItem(
              icon: Icons.play_circle_outline_rounded,
              title: 'Videos de técnica',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const VideosSocioScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 6. Configuración
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // 7. Ayuda y soporte
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Ayuda y soporte',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Soporte de gimnasio: soporte@gymtrack.com'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // 8. Cerrar sesión
            _buildMenuItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              isDestructive: true,
              onTap: () => _handleLogout(context),
            ),

            const SizedBox(height: 36),

            // Versión de la app
            const Center(
              child: Text(
                'GYMTRACK v2.1.0',
                style: TextStyle(
                  color: Color(0xFF6E6E73),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? const Color(0xFFEF4444) : const Color(0xFF7DE610);
    final textColor = isDestructive ? const Color(0xFFEF4444) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF282828),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6E6E73),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
