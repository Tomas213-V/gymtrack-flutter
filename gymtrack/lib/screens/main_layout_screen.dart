import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/gym_app_bar.dart';
import 'home_screen.dart';
import 'menu_secciones_screen.dart';
import 'pagos_screen.dart';
import 'socios_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final UserModel user;
  final int initialIndex;

  const MainLayoutScreen({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
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
      HomeScreen(
        user: widget.user,
        onNavigateToTab: _onTabTapped,
      ),
      const SociosScreen(),
      const PagosScreen(),
      _buildPlaceholderTab(
        title: 'Asistencia',
        icon: Icons.assignment_outlined,
        description: 'Control de asistencia y accesos con código QR / DNI para socios.',
      ),
      MenuSeccionesScreen(
        user: widget.user,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: const GymAppBar(),
      drawer: GymDrawer(user: widget.user),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E1315),
          border: Border(
            top: BorderSide(color: Color(0xFF1E282D), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
                _buildNavItem(1, Icons.person_outline_rounded, 'Socios'),
                _buildNavItem(2, Icons.attach_money_rounded, 'Pagos'),
                _buildNavItem(3, Icons.assignment_outlined, 'Asistencia'),
                _buildNavItem(4, Icons.more_horiz_rounded, 'Más'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF00E676);
    const inactiveColor = Color(0xFF7A8B94);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF00E676), size: 36),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF8F9CA3),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
