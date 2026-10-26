import 'package:flutter/material.dart';
import '../../mock/socio_mock_data.dart';
import '../../models/socio_dashboard_model.dart';
import '../../services/socio_dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/socio/qr_checkin_dialog.dart';
import '../../widgets/socio/socio_badge.dart';
import 'perfil_socio_screen.dart';
import 'videos/videos_socio_screen.dart';

class DashboardSocioScreen extends StatefulWidget {
  final Function(int index)? onNavigateToTab;

  const DashboardSocioScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<DashboardSocioScreen> createState() => _DashboardSocioScreenState();
}

class _DashboardSocioScreenState extends State<DashboardSocioScreen> {
  final SocioDashboardService _service = SocioDashboardService();
  SocioDashboardModel? _dashboardData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    setState(() => _isLoading = true);
    final data = await _service.getDashboard();
    if (!mounted) return;
    setState(() {
      _dashboardData = data;
      _isLoading = false;
    });
  }

  void _abrirQrCheckin() {
    QrCheckinDialog.show(
      context,
      onCheckinExitoso: _cargarDashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockProfile = SocioMockData().profile;

    final nombreSocio = _dashboardData?.socio.nombre.isNotEmpty == true
        ? _dashboardData!.socio.nombre
        : mockProfile.nombre;
    final planNombre = _dashboardData?.membresia.plan ?? mockProfile.plan;
    final estadoMembresia = _dashboardData?.membresia.isActiva == true ? 'activa' : mockProfile.estado;
    final fechaVencimiento = _dashboardData?.membresia.fechaVencimiento ?? mockProfile.fechaVencimiento;
    final ultimoPago = _dashboardData?.ultimoPago?.montoFormateado ?? mockProfile.ultimoPago;
    final pesoActual = _dashboardData?.progreso.pesoActual ?? mockProfile.pesoActual;
    final entrenamientosMes = _dashboardData?.entrenamientos.asistenciasMes ?? mockProfile.entrenamientosMes;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
            children: [
              TextSpan(
                text: 'GYM',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'TRACK',
                style: TextStyle(color: Color(0xFF7DE610)),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF282828),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF7DE610),
                size: 20,
              ),
              tooltip: 'Check-in QR',
              onPressed: _abrirQrCheckin,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF282828),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No tienes notificaciones pendientes'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF7DE610),
          backgroundColor: const Color(0xFF1B1B1B),
          onRefresh: _cargarDashboard,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: Color(0xFF7DE610),
                    backgroundColor: Color(0xFF222222),
                    minHeight: 2.5,
                  ),
                ),
              // Saludo al socio

              Row(
                children: [
                  Text(
                    '¡Hola, $nombreSocio! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Bienvenido a tu gimnasio',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 18),

              // Banner / CTA para Check-in QR
              InkWell(
                onTap: _abrirQrCheckin,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F2D14), Color(0xFF161E10)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7DE610).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7DE610).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(

                          color: const Color(0xFF7DE610),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Check-in con QR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFF7DE610),
                                  size: 18,
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Escaneá el código en el gimnasio para ingresar',
                              style: TextStyle(
                                color: Color(0xFFA1A1AA),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF7DE610),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Tarjeta de Membresía
              InkWell(
                onTap: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(3); // Pestaña Membresía
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF282828),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Membresía',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                planNombre,
                                style: const TextStyle(
                                  color: Color(0xFF7DE610),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SocioBadge.active(text: estadoMembresia),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VENCE EL',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fechaVencimiento,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'ÚLTIMO PAGO',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ultimoPago,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección Acciones Rápidas
              const Text(
                'Acciones rápidas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Check-in QR',
                      onTap: _abrirQrCheckin,
                      isHighlight: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Mi Rutina',
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.show_chart_rounded,
                      label: 'Progreso',
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.credit_card_rounded,
                      label: 'Membresía',
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(3);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.person_outline_rounded,
                      label: 'Perfil',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PerfilSocioScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Videos',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const VideosSocioScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Sección Resumen de progreso
              const Text(
                'Resumen de progreso',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Tarjeta 1: Peso actual
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(2);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B1B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF282828),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Peso actual',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${pesoActual.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Color(0xFF7DE610),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${mockProfile.cambioMes.abs()} kg este mes',
                                  style: const TextStyle(
                                    color: Color(0xFF7DE610),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tarjeta 2: Entrenamientos
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B1B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF282828),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Entrenamientos',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$entrenamientosMes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Completados este mes',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFF1E2818) : const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight ? const Color(0xFF7DE610).withValues(alpha: 0.5) : const Color(0xFF282828),
            width: isHighlight ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7DE610).withValues(alpha: isHighlight ? 0.25 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7DE610),
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isHighlight ? const Color(0xFF7DE610) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
