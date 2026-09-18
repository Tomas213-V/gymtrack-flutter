import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dashboard_socio_screen.dart';
import 'mas_socio_screen.dart';
import 'mi_membresia_screen.dart';
import 'mi_progreso_screen.dart';
import 'mi_rutina_screen.dart';

class SocioMainLayoutScreen extends StatefulWidget {
  final int initialIndex;

  const SocioMainLayoutScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<SocioMainLayoutScreen> createState() => _SocioMainLayoutScreenState();
}

class _SocioMainLayoutScreenState extends State<SocioMainLayoutScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardSocioScreen(
        onNavigateToTab: _onTabTapped,
      ),
      const MiRutinaScreen(
        showBackButton: false,
      ),
      const MiProgresoScreen(
        showBackButton: false,
      ),
      const MiMembresiaScreen(
        showBackButton: false,
      ),
      MasSocioScreen(
        onNavigateToTab: _onTabTapped,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          border: Border(
            top: BorderSide(color: Color(0xFF222222), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Inicio'),
                _buildNavItem(1, Icons.fitness_center_rounded, 'Rutina'),
                _buildNavItem(2, Icons.show_chart_rounded, 'Progreso'),
                _buildNavItem(3, Icons.credit_card_rounded, 'Membresía'),
                _buildNavItem(4, Icons.menu_rounded, 'Más'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF7DE610);
    const inactiveColor = Color(0xFF71717A);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
