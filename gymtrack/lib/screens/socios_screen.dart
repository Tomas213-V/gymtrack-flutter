import 'package:flutter/material.dart';
import '../models/socio_model.dart';
import '../services/socio_service.dart';

class SociosScreen extends StatefulWidget {
  const SociosScreen({super.key});

  @override
  State<SociosScreen> createState() => _SociosScreenState();
}

class _SociosScreenState extends State<SociosScreen> {
  final SocioService _socioService = SocioService();
  final TextEditingController _searchController = TextEditingController();

  List<SocioModel> _socios = [];
  SocioStatsModel _stats = SocioStatsModel.defaultStats();
  bool _isLoading = true;
  String _selectedTab = 'todos'; // 'todos', 'activo', 'pendiente', 'inactivo'
  int _currentPage = 1;
  int _totalPages = 3;
  int _totalSocios = 128;

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

    final stats = await _socioService.getStats();
    final result = await _socioService.getSocios(
      page: _currentPage,
      limit: 6,
      estado: _selectedTab,
      search: _searchController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _stats = stats;
      _socios = result['socios'] as List<SocioModel>;
      _totalSocios = result['total'] as int? ?? _stats.total;
      _totalPages = result['totalPages'] as int? ?? 1;
      _isLoading = false;
    });
  }

  void _onTabChanged(String tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
      _currentPage = 1;
    });
    _loadData();
  }

  void _onSearchChanged(String query) {
    _loadData();
  }

  void _showNewSocioModal() {
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final dniCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    String selectedPlan = 'Plan Mensual';
    String selectedEstado = 'activo';
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
                            'Nuevo Socio',
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
                        controller: nombreCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Nombre *', Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: apellidoCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Apellido *', Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: dniCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('DNI *', Icons.badge_outlined),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: telCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('Teléfono', Icons.phone_outlined),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPlan,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Plan', Icons.card_membership_outlined),
                        items: ['Plan Mensual', 'Plan Trimestral', 'Plan Anual']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedPlan = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEstado,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Estado', Icons.toggle_on_outlined),
                        items: [
                          const DropdownMenuItem(value: 'activo', child: Text('Activo')),
                          const DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                          const DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
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

                                  final ok = await _socioService.createSocio(
                                    nombre: nombreCtrl.text.trim(),
                                    apellido: apellidoCtrl.text.trim(),
                                    dni: dniCtrl.text.trim(),
                                    telefono: telCtrl.text.trim(),
                                    plan: selectedPlan,
                                    estado: selectedEstado,
                                    fechaVencimiento: '25 May 2026',
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? 'Socio registrado con éxito'
                                            : 'Socio guardado localmente'),
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
                                  'GUARDAR SOCIO',
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
                // 1. Título de sección y botón + Nuevo Socio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_alt_outlined,
                        color: Color(0xFF00E676),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Socios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gestiona y consulta todos los socios de tu gimnasio',
                            style: TextStyle(
                              color: Color(0xFF8F9CA3),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón + Nuevo socio
                    ElevatedButton.icon(
                      onPressed: _showNewSocioModal,
                      icon: const Icon(Icons.add, size: 16, color: Colors.black),
                      label: const Text(
                        'Nuevo socio',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Buscador y Filtros (2)
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
                          onChanged: _onSearchChanged,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Buscar socio por nombre, DNI o teléfono...',
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
                      child: Row(
                        children: [
                          const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Filtros',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E676),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 3. Tarjetas de métricas (4 métricas)
                SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildMetricCard(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF00E676),
                        value: _stats.total.toString(),
                        label: 'Total socios',
                        subtext: '↑ ${_stats.nuevosEsteMes} este mes',
                        subtextColor: const Color(0xFF00E676),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF00E676),
                        value: _stats.activos.toString(),
                        label: 'Activos',
                        subtext: '${_stats.pctActivos}% del total',
                        subtextColor: const Color(0xFF00E676),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        value: _stats.pendientes.toString(),
                        label: 'Pendientes',
                        subtext: '${_stats.pctPendientes}% del total',
                        subtextColor: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        icon: Icons.cancel_outlined,
                        iconColor: const Color(0xFFEF4444),
                        value: _stats.inactivos.toString(),
                        label: 'Inactivos',
                        subtext: '${_stats.pctInactivos}% del total',
                        subtextColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Pestañas de filtro (Todos, Activos, Pendientes, Inactivos)
                Row(
                  children: [
                    _buildFilterTab('Todos', 'todos'),
                    const SizedBox(width: 20),
                    _buildFilterTab('Activos', 'activo'),
                    const SizedBox(width: 20),
                    _buildFilterTab('Pendientes', 'pendiente'),
                    const SizedBox(width: 20),
                    _buildFilterTab('Inactivos', 'inactivo'),
                  ],
                ),

                const SizedBox(height: 14),

                // 5. Listado de socios
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: Color(0xFF00E676)),
                    ),
                  )
                else if (_socios.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: const Text(
                      'No se encontraron socios para este filtro.',
                      style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 14),
                    ),
                  )
                else
                  ..._socios.map((socio) => _buildSocioCard(socio)),

                const SizedBox(height: 14),

                // 6. Paginación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mostrando 1 - ${_socios.length} de $_totalSocios socios',
                      style: const TextStyle(color: Color(0xFF8F9CA3), fontSize: 12),
                    ),
                    Row(
                      children: [
                        _buildPageNavButton(
                          icon: Icons.chevron_left_rounded,
                          enabled: _currentPage > 1,
                          onPressed: () {
                            if (_currentPage > 1) {
                              setState(() => _currentPage--);
                              _loadData();
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildPageNumberButton(1, _currentPage == 1),
                        const SizedBox(width: 4),
                        _buildPageNumberButton(2, _currentPage == 2),
                        const SizedBox(width: 4),
                        _buildPageNumberButton(3, _currentPage == 3),
                        const SizedBox(width: 4),
                        _buildPageNavButton(
                          icon: Icons.chevron_right_rounded,
                          enabled: _currentPage < _totalPages,
                          onPressed: () {
                            if (_currentPage < _totalPages) {
                              setState(() => _currentPage++);
                              _loadData();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String subtext,
    required Color subtextColor,
  }) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243037), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8F9CA3),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Text(
            subtext,
            style: TextStyle(
              color: subtextColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedTab == value;

    return GestureDetector(
      onTap: () => _onTabChanged(value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00E676) : const Color(0xFF8F9CA3),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 24,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocioCard(SocioModel socio) {
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (socio.isActivo) {
      badgeBg = const Color(0xFF133820);
      badgeText = const Color(0xFF00E676);
      badgeLabel = 'Activo';
    } else if (socio.isPendiente) {
      badgeBg = const Color(0xFF3E2E14);
      badgeText = const Color(0xFFF59E0B);
      badgeLabel = 'Pendiente';
    } else {
      badgeBg = const Color(0xFF3E1818);
      badgeText = const Color(0xFFEF4444);
      badgeLabel = 'Inactivo';
    }

    final isVencido = socio.fechaVencimiento?.toLowerCase().contains('vencid') == true;

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
          // Avatar con icono de usuario
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

          // Nombre, DNI y Teléfono
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  socio.nombreCompleto.isNotEmpty ? socio.nombreCompleto : 'Socio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'DNI: ${socio.dni}',
                  style: const TextStyle(
                    color: Color(0xFF8F9CA3),
                    fontSize: 12,
                  ),
                ),
                if (socio.telefono != null && socio.telefono!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Color(0xFF8F9CA3), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        socio.telefono!,
                        style: const TextStyle(
                          color: Color(0xFF8F9CA3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Estado, Plan, Vencimiento y Flecha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
              const SizedBox(height: 4),
              Text(
                socio.plan ?? 'Plan Mensual',
                style: const TextStyle(
                  color: Color(0xFF8F9CA3),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                socio.fechaVencimiento ?? 'Vence 25 May 2026',
                style: TextStyle(
                  color: isVencido ? const Color(0xFFEF4444) : const Color(0xFF00E676),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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

  Widget _buildPageNumberButton(int page, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentPage = page);
        _loadData();
      },
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E676) : const Color(0xFF1E282D),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1E282D),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.white24,
        ),
      ),
    );
  }
}
