import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'dueno/videos/videos_dueno_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;
  final bool showAppBar;
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.user,
    this.showAppBar = false,
    this.onNavigateToTab,
  });

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
            const Text(
              'Descarga o consulta el balance mensual de ingresos, socios inscritos y asistencias.',
              style: TextStyle(color: Color(0xFF8A98A0), fontSize: 14),
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
                  if (onNavigateToTab != null) {
                    onNavigateToTab!(2); // Ir a Pagos/Resumen
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
    final displayName = user.nombre.trim().isNotEmpty
        ? user.nombre.trim().toUpperCase()
        : 'MARTÍN';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: showAppBar
          ? AppBar(
              backgroundColor: const Color(0xFF161D21),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () => _handleLogout(context),
                )
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        const Text(
                          'Resumen general de tu gimnasio',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A98A0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chip desplegable de fecha "Hoy, 24 May"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161D21),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF243037)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFFB0BEC5)),
                        SizedBox(width: 6),
                        Text(
                          'Hoy, 24 May',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFFB0BEC5)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Grilla 2x2 de Tarjetas de Métricas (KPIs)
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
                      value: '128',
                      bottomText: '▲ 5 este mes',
                      bottomTextColor: const Color(0xFF00E676),
                      onInfoTap: () => _showInfoDialog(
                        context,
                        'Socios Activos',
                        'Total de socios con membresía vigente al día de hoy.',
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
                      title: 'Socios activos',
                      value: '\$ 82.450',
                      bottomText: '▲ 12% vs ayer',
                      bottomTextColor: const Color(0xFF00E676),
                      onInfoTap: () => _showInfoDialog(
                        context,
                        'Ingresos',
                        'Recaudación acumulada por cuotas y membresías.',
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
                      title: 'Socios activos',
                      value: '18',
                      bottomText: 'Ver detalle',
                      bottomTextColor: const Color(0xFFFFB300),
                      onBottomTap: () {
                        if (onNavigateToTab != null) {
                          onNavigateToTab!(1); // Ir a Socios
                        }
                      },
                      onInfoTap: () => _showInfoDialog(
                        context,
                        'Por Vencer',
                        'Socios cuyas membresías vencen en los próximos 7 días.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tarjeta 4: En el gym / tiempo real
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      icon: Icons.login_rounded,
                      iconColor: const Color(0xFF03A9F4),
                      iconBgColor: const Color(0xFF03A9F4).withValues(alpha: 0.12),
                      title: 'Socios activos',
                      value: '73',
                      bottomText: 'En tiempo real',
                      bottomTextColor: const Color(0xFF03A9F4),
                      onInfoTap: () => _showInfoDialog(
                        context,
                        'Asistencias en Tiempo Real',
                        'Socios registrados en sala durante el turno actual.',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // 3. Sección de Acciones Rápidas
              const Text(
                'Acciones rapidas',
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
                      if (onNavigateToTab != null) {
                        onNavigateToTab!(1); // Pestaña Socios
                      }
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.attach_money_rounded,
                    label: 'Registrar\npago',
                    onTap: () {
                      if (onNavigateToTab != null) {
                        onNavigateToTab!(2); // Pestaña Pagos
                      }
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Marcar\nasistencia',
                    onTap: () {
                      if (onNavigateToTab != null) {
                        onNavigateToTab!(3); // Pestaña Asistencia
                      }
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

              const SizedBox(height: 22),

              // 4. Paneles Inferiores: Próximos vencimientos & Actividad reciente
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panel Izquierdo: Próximos vencimientos
                  Expanded(
                    child: _buildVencimientosCard(context),
                  ),
                  const SizedBox(width: 12),
                  // Panel Derecho: Actividad reciente
                  Expanded(
                    child: _buildActividadCard(context),
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
          // Fila superior: Icono + Título + Info icon
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

          // Valor numérico grande
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

          // Texto inferior o enlace
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

  // Widget para botón de Acción Rápida
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

  // Panel Izquierdo: Próximos Vencimientos
  Widget _buildVencimientosCard(BuildContext context) {
    final sociosVencimientos = [
      {'nombre': 'Luciano G.', 'vence': 'Vence 25 may', 'precio': '\$12.500', 'color': const Color(0xFFFF9800)},
      {'nombre': 'Camila R.', 'vence': 'Vence 26 may', 'precio': '\$12.500', 'color': const Color(0xFFFF9800)},
      {'nombre': 'Nicolás T.', 'vence': 'Vence 28 may', 'precio': '\$12.500', 'color': const Color(0xFFFF9800)},
      {'nombre': 'Agustín P.', 'vence': 'Vence 28 may', 'precio': '\$12.500', 'color': const Color(0xFFF44336)},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243037)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximos vencimientos',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A98A0),
            ),
          ),
          const SizedBox(height: 10),

          ...sociosVencimientos.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF00E676),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nombre'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item['vence'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF7A8B94),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['precio'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 2),
          Center(
            child: InkWell(
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(1); // Ir a Socios
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Panel Derecho: Actividad Reciente
  Widget _buildActividadCard(BuildContext context) {
    final actividades = [
      {
        'titulo': 'Check-in realizado',
        'subtitulo': 'Juan Perez',
        'hora': '09:15',
        'icon': Icons.check_circle_rounded,
        'iconColor': const Color(0xFF4CAF50),
      },
      {
        'titulo': 'Pago Registrado',
        'subtitulo': 'Juan Perez',
        'hora': '09:15',
        'icon': Icons.monetization_on_rounded,
        'iconColor': const Color(0xFF4CAF50),
      },
      {
        'titulo': 'Nuevo socio',
        'subtitulo': 'Juan Perez',
        'hora': '08:45',
        'icon': Icons.people_rounded,
        'iconColor': const Color(0xFFFFB300),
      },
      {
        'titulo': 'Nuevo video agregado',
        'subtitulo': 'Juan Perez',
        'hora': '05:25',
        'icon': Icons.play_circle_rounded,
        'iconColor': const Color(0xFFAB47BC),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243037)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad reciente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A98A0),
            ),
          ),
          const SizedBox(height: 10),

          ...actividades.map((act) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    act['icon'] as IconData,
                    color: act['iconColor'] as Color,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act['titulo'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          act['subtitulo'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF7A8B94),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    act['hora'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF7A8B94),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 2),
          Center(
            child: InkWell(
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(3); // Ir a Asistencia/Actividad
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
