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
                              fontSize: 18,
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
                        items: const [
                          DropdownMenuItem(value: 'activo', child: Text('Activo')),
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEstado = val);
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 46,
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
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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

  void _showSocioDetailModal(SocioModel socio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      socio.nombreCompleto.isNotEmpty ? socio.nombreCompleto : 'Socio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailItem(Icons.badge_outlined, 'DNI', socio.dni),
              if (socio.telefono != null && socio.telefono!.isNotEmpty)
                _buildDetailItem(Icons.phone_outlined, 'Teléfono', socio.telefono!),
              _buildDetailItem(Icons.card_membership_outlined, 'Plan', socio.plan ?? 'Plan Mensual'),
              _buildDetailItem(Icons.event_available_outlined, 'Vencimiento', socio.fechaVencimiento ?? '25 May 2026'),
              _buildDetailItem(Icons.toggle_on_outlined, 'Estado', socio.estado.toUpperCase()),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E282D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF2B3A42)),
                    ),
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00E676)),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: Color(0xFF8F9CA3), fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
                // 1. Encabezado limpio y botón + Nuevo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Socios',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_totalSocios socios registrados',
                          style: const TextStyle(
                            color: Color(0xFF8F9CA3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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

                const SizedBox(height: 14),

                // 2. Buscador responsivo y limpio
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF27343B), width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar socio por nombre o DNI...',
                      hintStyle: const TextStyle(color: Color(0xFF6B7B84), fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8F9CA3), size: 19),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF8F9CA3), size: 16),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Barra unificada de métricas (Compacta, interactiva y sin desbordes)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E22),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF243037), width: 1),
                  ),
                  child: Row(
                    children: [
                      _buildStatColumn('Total', _stats.total.toString(), Colors.white, 'todos'),
                      _buildStatDivider(),
                      _buildStatColumn('Activos', _stats.activos.toString(), const Color(0xFF00E676), 'activo'),
                      _buildStatDivider(),
                      _buildStatColumn('Pendientes', _stats.pendientes.toString(), const Color(0xFFF59E0B), 'pendiente'),
                      _buildStatDivider(),
                      _buildStatColumn('Inactivos', _stats.inactivos.toString(), const Color(0xFFEF4444), 'inactivo'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Pestañas de filtro rápidas
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab('Todos', 'todos'),
                      const SizedBox(width: 16),
                      _buildFilterTab('Activos', 'activo'),
                      const SizedBox(width: 16),
                      _buildFilterTab('Pendientes', 'pendiente'),
                      const SizedBox(width: 16),
                      _buildFilterTab('Inactivos', 'inactivo'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 5. Listado de socios con diseño espacioso y sin overflows
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: CircularProgressIndicator(color: Color(0xFF00E676)),
                    ),
                  )
                else if (_socios.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: const Text(
                      'No se encontraron socios para este filtro.',
                      style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
                    ),
                  )
                else
                  ..._socios.map((socio) => _buildSocioCard(socio)),

                const SizedBox(height: 10),

                // 6. Paginación compacta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_socios.length} de $_totalSocios socios',
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
                        if (_totalPages >= 2) ...[
                          const SizedBox(width: 4),
                          _buildPageNumberButton(2, _currentPage == 2),
                        ],
                        if (_totalPages >= 3) ...[
                          const SizedBox(width: 4),
                          _buildPageNumberButton(3, _currentPage == 3),
                        ],
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color, String tabValue) {
    final isSelected = _selectedTab == tabValue;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(tabValue),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E282D) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8F9CA3),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFF243037),
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
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 2,
            width: 22,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de socio optimizada, moderna y sin desbordes
  Widget _buildSocioCard(SocioModel socio) {
    Color badgeBg;
    Color badgeBorder;
    Color badgeText;
    String badgeLabel;

    if (socio.isActivo) {
      badgeBg = const Color(0xFF0F381E);
      badgeBorder = const Color(0xFF1B5E20);
      badgeText = const Color(0xFF00E676);
      badgeLabel = 'Activo';
    } else if (socio.isPendiente) {
      badgeBg = const Color(0xFF382A0F);
      badgeBorder = const Color(0xFFB45309);
      badgeText = const Color(0xFFF59E0B);
      badgeLabel = 'Pendiente';
    } else {
      badgeBg = const Color(0xFF381414);
      badgeBorder = const Color(0xFFB91C1C);
      badgeText = const Color(0xFFEF4444);
      badgeLabel = 'Inactivo';
    }

    final isVencido = socio.fechaVencimiento?.toLowerCase().contains('vencid') == true || socio.isInactivo;

    final initials = (socio.nombre.isNotEmpty ? socio.nombre[0] : '') +
        (socio.apellido.isNotEmpty ? socio.apellido[0] : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243037), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showSocioDetailModal(socio),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Avatar + Nombre / DNI + Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar con iniciales
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isNotEmpty ? initials.toUpperCase() : 'S',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nombre y DNI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            socio.nombreCompleto.isNotEmpty ? socio.nombreCompleto : 'Socio',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'DNI: ${socio.dni}',
                                style: const TextStyle(
                                  color: Color(0xFF8F9CA3),
                                  fontSize: 12,
                                ),
                              ),
                              if (socio.telefono != null && socio.telefono!.isNotEmpty) ...[
                                const Text(' • ', style: TextStyle(color: Color(0xFF5A6B74), fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    socio.telefono!,
                                    style: const TextStyle(
                                      color: Color(0xFF8F9CA3),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Badge de Estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: badgeBorder, width: 0.8),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          color: badgeText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                // Línea separadora sutil
                const Divider(height: 1, color: Color(0xFF222C31)),

                const SizedBox(height: 7),

                // Fila Inferior: Plan + Vencimiento + Flecha
                Row(
                  children: [
                    const Icon(Icons.card_membership_rounded, size: 13, color: Color(0xFF8F9CA3)),
                    const SizedBox(width: 4),
                    Text(
                      socio.plan ?? 'Plan Mensual',
                      style: const TextStyle(
                        color: Color(0xFF8F9CA3),
                        fontSize: 11.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isVencido ? Icons.error_outline_rounded : Icons.event_available_rounded,
                      size: 13,
                      color: isVencido ? const Color(0xFFEF4444) : const Color(0xFF00E676),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      socio.fechaVencimiento ?? '25 May 2026',
                      style: TextStyle(
                        color: isVencido ? const Color(0xFFEF4444) : const Color(0xFF00E676),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 15, color: Color(0xFF5A6B74)),
                  ],
                ),
              ],
            ),
          ),
        ),
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
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E676) : const Color(0xFF1E282D),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontSize: 11,
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
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF1E282D),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled ? Colors.white : Colors.white24,
        ),
      ),
    );
  }
}
