import 'package:flutter/material.dart';
import '../../models/socio_dashboard_model.dart';
import '../../services/socio_dashboard_service.dart';
import '../../theme/app_theme.dart';

class PlanesDisponiblesScreen extends StatefulWidget {
  final int? idPlanActual;
  final VoidCallback? onPlanActualizado;

  const PlanesDisponiblesScreen({
    super.key,
    this.idPlanActual,
    this.onPlanActualizado,
  });

  @override
  State<PlanesDisponiblesScreen> createState() => _PlanesDisponiblesScreenState();
}

class _PlanesDisponiblesScreenState extends State<PlanesDisponiblesScreen> {
  final SocioDashboardService _service = SocioDashboardService();
  bool _isLoading = true;
  List<PlanDisponibleModel> _planes = [];

  @override
  void initState() {
    super.initState();
    _cargarPlanes();
  }

  Future<void> _cargarPlanes() async {
    setState(() => _isLoading = true);
    final lista = await _service.getPlanesDisponibles();

    if (!mounted) return;

    if (lista.isEmpty) {
      // Planes de demostración predeterminados para asegurar una experiencia visual impecable
      _planes = [
        PlanDisponibleModel(
          idPlanMembresia: 1,
          nombre: 'Plan Básico',
          precio: 15000,
          precioFormateado: '\$15.000',
          duracionDias: 30,
          duracionTexto: '30 días',
          esPlanActual: widget.idPlanActual == 1,
          beneficios: [
            'Acceso de lunes a viernes',
            'Sala de musculación y peso libre',
            'Evaluación inicial con profesor',
            'App de seguimiento de asistencias',
          ],
        ),
        PlanDisponibleModel(
          idPlanMembresia: 2,
          nombre: 'Plan Premium',
          precio: 22000,
          precioFormateado: '\$22.000',
          duracionDias: 30,
          duracionTexto: '30 días',
          esPlanActual: widget.idPlanActual == 2,
          esSuperior: widget.idPlanActual != 2,
          diferenciaPrecio: 7000,
          diferenciaPrecioFormateada: '\$7.000',
          beneficios: [
            'Acceso completo de lunes a sábado',
            'Sala de musculación y máquinas guiadas',
            'Hasta 3 clases grupales por semana',
            'Rutina personalizada inicial',
            'Descuentos en suplementos y merchandising',
          ],
        ),
        PlanDisponibleModel(
          idPlanMembresia: 3,
          nombre: 'Pase Libre Total',
          precio: 28000,
          precioFormateado: '\$28.000',
          duracionDias: 30,
          duracionTexto: '30 días',
          esPlanActual: widget.idPlanActual == 3,
          esSuperior: true,
          diferenciaPrecio: 13000,
          diferenciaPrecioFormateada: '\$13.000',
          beneficios: [
            'Acceso ilimitado todos los días y horarios',
            'Acceso libre a sala de musculación y cardio',
            'Todas las clases grupales incluidas',
            'Plan de entrenamiento y seguimiento VIP',
            'Acceso a vestuarios y casilleros premium',
          ],
        ),
      ];
    } else {
      _planes = lista;
    }

    setState(() => _isLoading = false);
  }

  void _abrirModalPago(PlanDisponibleModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModalProcesoPago(
        plan: plan,
        onPagoConfirmado: () {
          if (widget.onPlanActualizado != null) {
            widget.onPlanActualizado!();
          }
          _cargarPlanes();
        },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Planes Disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF7DE610)),
              )
            : RefreshIndicator(
                color: const Color(0xFF7DE610),
                backgroundColor: const Color(0xFF1B1B1B),
                onRefresh: _cargarPlanes,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Subtítulo
                    const Text(
                      'Elige o renueva tu plan de entrenamiento',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tarjetas de Planes
                    ..._planes.map((plan) => _buildPlanCard(plan)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPlanCard(PlanDisponibleModel plan) {
    final esActual = plan.esPlanActual;
    final esRecomendado = plan.nombre.toLowerCase().contains('libre') ||
        plan.nombre.toLowerCase().contains('premium');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: esActual
              ? const Color(0xFF7DE610)
              : esRecomendado
                  ? const Color(0xFF383838)
                  : const Color(0xFF262626),
          width: esActual ? 2 : 1,
        ),
        boxShadow: esActual
            ? [
                BoxShadow(
                  color: const Color(0xFF7DE610).withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del Plan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.duracionTexto} de vigencia',
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (esActual)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DE610).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF7DE610)),
                  ),

                  child: const Text(
                    'Plan Actual',
                    style: TextStyle(
                      color: Color(0xFF7DE610),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (plan.esSuperior && plan.diferenciaPrecioFormateada != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${plan.diferenciaPrecioFormateada}',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.precioFormateado,
                style: const TextStyle(
                  color: Color(0xFF7DE610),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '/ período',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF282828), height: 1),
          const SizedBox(height: 16),

          // Beneficios
          const Text(
            'BENEFICIOS INCLUIDOS',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          ...plan.beneficios.map((beneficio) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF7DE610),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      beneficio,
                      style: const TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Botón de Acción
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _abrirModalPago(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: esActual ? const Color(0xFF2A2A2A) : const Color(0xFF7DE610),
                foregroundColor: esActual ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                esActual ? 'Renovar este Plan' : 'Elegir y Activar Plan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalProcesoPago extends StatefulWidget {
  final PlanDisponibleModel plan;
  final VoidCallback onPagoConfirmado;

  const _ModalProcesoPago({
    required this.plan,
    required this.onPagoConfirmado,
  });

  @override
  State<_ModalProcesoPago> createState() => _ModalProcesoPagoState();
}

class _ModalProcesoPagoState extends State<_ModalProcesoPago> {
  final SocioDashboardService _service = SocioDashboardService();
  String _metodoSeleccionado = 'mercadopago';
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _confirmarOperacion() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final res = await _service.confirmarPago(
      idPlanMembresia: widget.plan.idPlanMembresia,
      monto: widget.plan.precio,
      metodoPago: _metodoSeleccionado,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (res['success'] == true) {
      widget.onPagoConfirmado();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  res['mensaje'] ?? '¡Plan actualizado exitosamente!',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF7DE610),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setState(() {
        _errorMessage = res['error'] ?? 'Error al procesar la actualización del plan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Confirmar Plan y Pago',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Resumen del Plan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plan.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vigencia: ${widget.plan.duracionTexto}',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.plan.precioFormateado,
                    style: const TextStyle(
                      color: Color(0xFF7DE610),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'MÉTODO DE PAGO',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            _buildPaymentOption(
              key: 'mercadopago',
              title: 'Mercado Pago / Tarjeta',
              subtitle: 'Débito, crédito o dinero en cuenta',
              icon: Icons.credit_card_rounded,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'efectivo',
              title: 'Efectivo en Mostrador',
              subtitle: 'Abonar presencialmente en el gimnasio',
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'transferencia',
              title: 'Transferencia Bancaria',
              subtitle: 'Enviar comprobante por recepción',
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _confirmarOperacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DE610),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Confirmar y Activar Membresía',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _metodoSeleccionado == key;

    return InkWell(
      onTap: () => setState(() => _metodoSeleccionado = key),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2818) : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF282828),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF8E8E93),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFE0E0E0),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF7DE610),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
