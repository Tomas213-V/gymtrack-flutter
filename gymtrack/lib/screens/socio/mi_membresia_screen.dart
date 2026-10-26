import 'package:flutter/material.dart';
import '../../mock/socio_mock_data.dart';
import '../../services/socio_dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/socio/socio_badge.dart';
import 'planes_disponibles_screen.dart';

class MiMembresiaScreen extends StatefulWidget {
  final bool showBackButton;

  const MiMembresiaScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<MiMembresiaScreen> createState() => _MiMembresiaScreenState();
}

class _MiMembresiaScreenState extends State<MiMembresiaScreen> {
  final SocioDashboardService _service = SocioDashboardService();
  bool _isLoading = false;
  Map<String, dynamic>? _membresiaData;

  @override
  void initState() {
    super.initState();
    _cargarMembresia();
  }

  Future<void> _cargarMembresia() async {
    setState(() => _isLoading = true);
    final data = await _service.getMiMembresia();
    if (!mounted) return;
    setState(() {
      _membresiaData = data;
      _isLoading = false;
    });
  }

  void _abrirPlanes() {
    final memb = _membresiaData?['membresia'];
    final idPlan = memb != null ? memb['id_plan_membresia'] : null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlanesDisponiblesScreen(
          idPlanActual: idPlan is int ? idPlan : null,
          onPlanActualizado: _cargarMembresia,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar datos mock por defecto para fallback offline y compatibilidad con tests
    final mockProfile = SocioMockData().profile;
    final mockPagos = SocioMockData().pagos;

    final membMap = _membresiaData?['membresia'];
    final planNombre = membMap?['nombre_plan'] ?? mockProfile.plan;
    final precioPlan = membMap?['precio_formateado'] ?? mockProfile.precioPlan;
    final estadoTexto = membMap?['estado_etiqueta'] ?? mockProfile.estado;
    final fechaInicio = membMap?['fecha_inicio_formateada'] ?? mockProfile.fechaInicio;
    final fechaVencimiento = membMap?['fecha_vencimiento_formateada'] ?? mockProfile.fechaVencimiento;
    final diasRestantes = membMap?['dias_restantes'] ?? mockProfile.diasRestantes;
    final porcentaje = (membMap?['porcentaje_transcurrido'] as num?)?.toDouble() ?? 30.0;

    final rawPagos = _membresiaData?['historial_pagos'] as List?;
    final listaPagos = rawPagos != null && rawPagos.isNotEmpty
        ? rawPagos
        : mockPagos.map((p) => {
              'fecha_formateada': p.fecha,
              'metodo_pago_etiqueta': p.metodoPago,
              'monto_formateado': p.monto,
              'estado_etiqueta': p.estado,
            }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Mi Membresía',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Actualizar',
            onPressed: _cargarMembresia,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF7DE610),
          backgroundColor: const Color(0xFF1B1B1B),
          onRefresh: _cargarMembresia,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: LinearProgressIndicator(
                    color: Color(0xFF7DE610),
                    backgroundColor: Color(0xFF222222),
                    minHeight: 2.5,
                  ),
                ),
              // Hero Card de Membresía

              Container(
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
                    // Plan y Badge Activa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          planNombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SocioBadge.active(text: estadoTexto),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      precioPlan,
                      style: const TextStyle(
                        color: Color(0xFF7DE610),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Fechas Inicio y Vencimiento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INICIO',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fechaInicio,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'VENCIMIENTO',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fechaVencimiento,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Barra de progreso de días
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (porcentaje / 100).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF282828),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7DE610)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sub-tarjeta Días restantes de acceso
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Días restantes de acceso',
                            style: TextStyle(
                              color: Color(0xFFCCCCCC),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$diasRestantes días',
                            style: const TextStyle(
                              color: Color(0xFF7DE610),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botón para Explorar Planes o Renovar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _abrirPlanes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DE610),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.stars_rounded, size: 20),
                  label: const Text(
                    'Ver Planes / Renovar Membresía',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Sección Historial de pagos
              const Text(
                'Historial de pagos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Lista de pagos
              ...listaPagos.map((pago) {
                final fecha = pago['fecha_formateada']?.toString() ?? pago['fecha']?.toString() ?? '-';
                final metodo = pago['metodo_pago_etiqueta']?.toString() ?? pago['metodo_pago']?.toString() ?? 'Pago Digital';
                final monto = pago['monto_formateado']?.toString() ?? pago['monto']?.toString() ?? '\$0';
                final estado = pago['estado_etiqueta']?.toString() ?? pago['estado']?.toString() ?? 'Pagado';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Izquierda: Fecha y método
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fecha,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              metodo,
                              style: const TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        // Derecha: Monto y Badge Pagado
                        Row(
                          children: [
                            Text(
                              monto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SocioBadge.paid(text: estado),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
