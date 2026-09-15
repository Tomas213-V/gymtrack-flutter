import 'package:flutter/material.dart';
import '../models/pago_model.dart';
import '../services/pago_service.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  final PagoService _pagoService = PagoService();
  final TextEditingController _searchController = TextEditingController();

  List<PagoModel> _pagos = [];
  ResumenPagosModel _resumen = ResumenPagosModel.defaultResumen();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final resumen = await _pagoService.getResumen();
    final pagos = await _pagoService.getPagos(
      search: _searchController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _resumen = resumen;
      _pagos = pagos;
      _isLoading = false;
    });
  }

  void _showRegistrarPagoModal() {
    final socioNombreCtrl = TextEditingController();
    final montoCtrl = TextEditingController(text: '18000');
    String selectedPlan = 'Plan Premium';
    String selectedMetodo = 'Efectivo';
    String selectedEstado = 'pagado';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Registrar Pago',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: socioNombreCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Nombre del Socio *', Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: montoCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Monto (\$) *', Icons.attach_money),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPlan,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Plan', Icons.card_membership_outlined),
                        items: ['Plan Básico', 'Plan Mensual', 'Plan Premium', 'Plan Anual']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedPlan = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMetodo,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Método de Pago', Icons.payments_outlined),
                        items: ['Efectivo', 'Transferencia', 'Tarjeta', 'Mercado Pago']
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedMetodo = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEstado,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Estado del Pago', Icons.check_circle_outline),
                        items: const [
                          DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEstado = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSaving = true);

                                  final monto = double.tryParse(montoCtrl.text.trim()) ?? 18000;
                                  final ok = await _pagoService.registrarPago(
                                    socioNombre: socioNombreCtrl.text.trim(),
                                    monto: monto,
                                    plan: selectedPlan,
                                    metodoPago: selectedMetodo,
                                    estado: selectedEstado,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? 'Pago registrado exitosamente'
                                            : 'Pago guardado'),
                                        backgroundColor: const Color(0xFF1B5E20),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    _loadData();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text(
                                  'REGISTRAR PAGO',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
      filled: true,
      fillColor: const Color(0xFF1E282D),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B3A42)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E676)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF00E676),
          backgroundColor: const Color(0xFF182024),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dos tarjetas de acción rápida
                Row(
                  children: [
                    // Tarjeta 1: Registrar pago
                    Expanded(
                      child: GestureDetector(
                        onTap: _showRegistrarPagoModal,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11251A),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF00E676).withValues(alpha: 0.8),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E676),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '\$',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Registrar pago',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Registrar un nuevo pago de un socio',
                                style: TextStyle(
                                  color: Color(0xFF8F9CA3),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tarjeta 2: Estado de cuota
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E22),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF243037),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF222D33),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF8F9CA3),
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Estado de cuota',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ver estado de cuotas de los socios',
                              style: TextStyle(
                                color: Color(0xFF8F9CA3),
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Buscador y Filtros
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF27343B), width: 1),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => _loadData(),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Buscar socio...',
                            hintStyle: TextStyle(color: Color(0xFF6B7B84), fontSize: 12),
                            prefixIcon: Icon(Icons.search, color: Color(0xFF8F9CA3), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF27343B), width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.tune_rounded, color: Color(0xFF00E676), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Filtros',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. Pagos recientes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pagos recientes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lista de tarjetas de pagos recientes
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(color: Color(0xFF00E676)),
                    ),
                  )
                else
                  ..._pagos.map((pago) => _buildPagoCard(pago)),

                const SizedBox(height: 20),

                // 4. Tarjeta Resumen de pagos (Este mes)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF243037), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumen de pagos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Este mes',
                                style: TextStyle(
                                  color: Color(0xFF8F9CA3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00E676), width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Ver estadísticas',
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 3 Columnas de métricas con separadores
                      Row(
                        children: [
                          // Columna 1: Total recaudado
                          Expanded(
                            child: _buildResumenMetric(
                              icon: const Text(
                                '\$',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              iconBg: const Color(0xFF8B5CF6),
                              value: _resumen.formattedTotalRecaudado,
                              label: 'Total recaudado',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: const Color(0xFF243037),
                          ),

                          // Columna 2: Pagos realizados
                          Expanded(
                            child: _buildResumenMetric(
                              icon: const Icon(Icons.check, color: Colors.black, size: 16),
                              iconBg: const Color(0xFF00E676),
                              value: _resumen.pagosRealizados.toString(),
                              label: 'Pagos realizados',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: const Color(0xFF243037),
                          ),

                          // Columna 3: Pendientes
                          Expanded(
                            child: _buildResumenMetric(
                              icon: const Icon(Icons.access_time_filled, color: Colors.black, size: 16),
                              iconBg: const Color(0xFFF59E0B),
                              value: _resumen.pagosPendientes.toString(),
                              label: 'Pendientes',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagoCard(PagoModel pago) {
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (pago.isPagado) {
      badgeBg = const Color(0xFF133820);
      badgeText = const Color(0xFF00E676);
      badgeLabel = 'Pagado';
    } else if (pago.isPendiente) {
      badgeBg = const Color(0xFF3E2E14);
      badgeText = const Color(0xFFF59E0B);
      badgeLabel = 'Pendiente';
    } else {
      badgeBg = const Color(0xFF3E1818);
      badgeText = const Color(0xFFEF4444);
      badgeLabel = 'Vencido';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243037), width: 1),
      ),
      child: Row(
        children: [
          // Avatar del socio
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.7), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF00E676),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Nombre, Plan y Fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pago.socioNombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pago.plan,
                  style: const TextStyle(
                    color: Color(0xFF8F9CA3),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pago.fechaPago,
                  style: const TextStyle(
                    color: Color(0xFF8F9CA3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Monto y Badge de estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pago.formattedMonto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7B84), size: 20),
        ],
      ),
    );
  }

  Widget _buildResumenMetric({
    required Widget icon,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F9CA3),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
