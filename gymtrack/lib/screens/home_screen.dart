import 'package:flutter/material.dart';
import '../models/dashboard_admin_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/dashboard_admin_service.dart';
import 'dueno/videos/videos_dueno_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final bool showAppBar;
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.user,
    this.showAppBar = false,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardAdminService _dashboardService = DashboardAdminService();
  DashboardAdminModel _dashboard = DashboardAdminModel.defaultMock();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    setState(() => _isLoading = true);
    final data = await _dashboardService.getDashboardAdmin(
      idGimnasio: widget.user.gimnasio?.idGimnasio,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _dashboard = data;
    });
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    return amount.toStringAsFixed(0);
  }

  void _handleLogout(BuildContext context) {
    AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showInfoDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161D21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(description, style: const TextStyle(color: Color(0xFFB0BEC5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF00E676))),
          ),
        ],
      ),
    );
  }

  void _showReportesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161D21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: Color(0xFF00E676), size: 28),
                SizedBox(width: 12),
                Text(
                  'Reportes y Estadísticas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recaudación mes actual: \$${_formatMoney(_dashboard.recaudacionMesActual)}\n'
              'Total de socios: ${_dashboard.totalSocios} (${_dashboard.sociosActivos} activos)\n'
              'Asistencias del mes: ${_dashboard.asistenciasMesActual}',
              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(2); // Ir a Pagos/Resumen
                  }
                },
                child: const Text('Ver Balance en Pagos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user.nombre.trim().isNotEmpty
        ? widget.user.nombre.trim().toUpperCase()
        : 'MARTÍN';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: const Color(0xFF161D21),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
                  onPressed: _cargarDashboard,
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () => _handleLogout(context),
                )
              ],
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00E676),
          backgroundColor: const Color(0xFF161E22),
          onRefresh: _cargarDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      color: Color(0xFF00E676),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                // 1. Encabezado de Saludo + Selector de Fecha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡HOLA $displayName! 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.user.gimnasio?.nombre ?? 'Resumen general de tu gimnasio',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A98A0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chip desplegable de estado en vivo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161D21),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF243037)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E676),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'En vivo',
                            style: TextStyle(
                              color: Color(0xFFB0BEC5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Grilla 2x2 de Tarjetas de Métricas (KPIs Reales)
                Row(
                  children: [
                    // Tarjeta 1: Socios activos
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.people_alt_outlined,
                        iconColor: const Color(0xFF00E676),
                        iconBgColor: const Color(0xFF00E676).withValues(alpha: 0.12),
                        title: 'Socios activos',
                        value: '${_dashboard.sociosActivos}',
                        bottomText: '▲ ${_dashboard.sociosNuevosMes} nuevos',
                        bottomTextColor: const Color(0xFF00E676),
                        onBottomTap: () {
                          if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                        },
                        onInfoTap: () => _showInfoDialog(
                          context,
                          'Socios Activos',
                          'Total de socios con membresía vigente al día de hoy. De un total registrado de ${_dashboard.totalSocios}.',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tarjeta 2: Ingresos
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.attach_money_rounded,
                        iconColor: const Color(0xFF00E676),
                        iconBgColor: const Color(0xFF00E676).withValues(alpha: 0.12),
                        title: 'Ingresos mes',
                        value: '\$ ${_formatMoney(_dashboard.recaudacionMesActual)}',
                        bottomText: '${_dashboard.variacionIngresos >= 0 ? "▲" : "▼"} ${_dashboard.variacionIngresos}% vs anterior',
                        bottomTextColor: _dashboard.variacionIngresos >= 0 ? const Color(0xFF00E676) : Colors.redAccent,
                        onBottomTap: () {
                          if (widget.onNavigateToTab != null) widget.onNavigateToTab!(2);
                        },
                        onInfoTap: () => _showInfoDialog(
                          context,
                          'Ingresos del Mes',
                          'Recaudación acumulada por cuotas y suscripciones durante el mes en curso.',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // Tarjeta 3: Por vencer
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.credit_card_outlined,
                        iconColor: const Color(0xFFFFB300),
                        iconBgColor: const Color(0xFFFFB300).withValues(alpha: 0.12),
                        title: 'Por vencer',
                        value: '${_dashboard.membresiasPorVencer}',
                        bottomText: '${_dashboard.membresiasVencidas} vencidas',
                        bottomTextColor: const Color(0xFFFFB300),
                        onBottomTap: () {
                          if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                        },
                        onInfoTap: () => _showInfoDialog(
                          context,
                          'Membresías por Vencer',
                          'Socios con membresías que vencen en los próximos 7 días, y ${_dashboard.membresiasVencidas} ya vencidas.',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tarjeta 4: Asistencias
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.login_rounded,
                        iconColor: const Color(0xFF03A9F4),
                        iconBgColor: const Color(0xFF03A9F4).withValues(alpha: 0.12),
                        title: 'Asistencias hoy',
                        value: '${_dashboard.asistenciasHoy}',
                        bottomText: '${_dashboard.asistenciasMesActual} en el mes',
                        bottomTextColor: const Color(0xFF03A9F4),
                        onBottomTap: () {
                          if (widget.onNavigateToTab != null) widget.onNavigateToTab!(3);
                        },
                        onInfoTap: () => _showInfoDialog(
                          context,
                          'Asistencias',
                          'Total de ingresos al gimnasio registrados hoy y acumulado mensual.',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 3. Sección de Acciones Rápidas
                const Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(
                      icon: Icons.person_add_alt_1_outlined,
                      label: 'Nuevo socio',
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.attach_money_rounded,
                      label: 'Registrar\npago',
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(2);
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Marcar\nasistencia',
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(3);
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Videos',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const VideosDuenoScreen()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reportes',
                      onTap: () => _showReportesModal(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Próximos Vencimientos / Actividad Reciente
                if (_dashboard.proximosVencimientos.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximos Vencimientos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                        },
                        child: const Text('Ver todos', style: TextStyle(color: Color(0xFF00E676), fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._dashboard.proximosVencimientos.take(4).map(
                    (v) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161D21),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF243037)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.schedule_rounded, color: Color(0xFFFFB300), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.socioNombre,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Plan ${v.plan} • Vence: ${v.fechaVencimiento?.split("T")[0] ?? "Pronto"}',
                                  style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF7A8B94), size: 18),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para tarjetas de métricas 2x2
  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String bottomText,
    required Color bottomTextColor,
    VoidCallback? onBottomTap,
    VoidCallback? onInfoTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243037)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A98A0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onInfoTap,
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: Color(0xFF7A8B94),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          GestureDetector(
            onTap: onBottomTap,
            child: Text(
              bottomText,
              style: TextStyle(
                fontSize: 11,
                color: bottomTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF161D21),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF243037)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              splashColor: const Color(0xFF00E676).withValues(alpha: 0.15),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFF00E676),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFB0BEC5),
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}
