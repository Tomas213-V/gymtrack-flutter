import 'package:flutter/material.dart';
import '../../../models/ejercicio_model.dart';
import '../../../services/ejercicio_service.dart';
import '../../../theme/app_theme.dart';

class SocioEjerciciosScreen extends StatefulWidget {
  const SocioEjerciciosScreen({super.key});

  @override
  State<SocioEjerciciosScreen> createState() => _SocioEjerciciosScreenState();
}

class _SocioEjerciciosScreenState extends State<SocioEjerciciosScreen> {
  final EjercicioService _ejercicioService = EjercicioService();

  List<EjercicioModel> _ejercicios = [];
  bool _isLoading = true;
  String _filtroOrigen = 'todos'; // 'todos' | 'gimnasio' | 'propio'
  String _filtroGrupo = 'todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _gruposMusculares = [
    'todos',
    'Pecho',
    'Espalda',
    'Piernas',
    'Hombros',
    'Brazos',
    'Core',
    'Cardio',
    'General',
  ];

  final List<String> _dificultades = [
    'Principiante',
    'Intermedia',
    'Avanzada',
  ];

  @override
  void initState() {
    super.initState();
    _cargarEjercicios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarEjercicios() async {
    setState(() => _isLoading = true);
    try {
      final list = await _ejercicioService.getEjerciciosSocio(
        origen: _filtroOrigen,
        grupoMuscular: _filtroGrupo,
        search: _searchQuery,
      );
      if (mounted) {
        setState(() {
          _ejercicios = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _abrirDialogoCrearEditar([EjercicioModel? item]) {
    final bool esEdicion = item != null;
    final nombreCtrl = TextEditingController(text: item?.nombre ?? '');
    final descCtrl = TextEditingController(text: item?.descripcion ?? '');
    String selectedGrupo = item?.grupoMuscular ?? 'Pecho';
    if (!_gruposMusculares.contains(selectedGrupo)) {
      selectedGrupo = 'General';
    }
    String selectedDificultad = item?.dificultad ?? 'Intermedia';
    if (!_dificultades.contains(selectedDificultad)) {
      selectedDificultad = 'Intermedia';
    }

    bool guardando = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1B1B1B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF282828)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DE610).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: Color(0xFF7DE610), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  esEdicion ? 'Editar Ejercicio Propio' : 'Nuevo Ejercicio Propio',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOMBRE DEL EJERCICIO *',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ej. Press declinado con mancuernas',
                      hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'GRUPO MUSCULAR',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedGrupo,
                    dropdownColor: const Color(0xFF222222),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: _gruposMusculares
                        .where((g) => g != 'todos')
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedGrupo = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'DIFICULTAD',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedDificultad,
                    dropdownColor: const Color(0xFF222222),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    items: _dificultades
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedDificultad = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'DESCRIPCIÓN / NOTAS (OPCIONAL)',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Añade indicaciones de agarre, postura o variaciones...',
                      hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: guardando ? null : () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DE610),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: guardando
                    ? null
                    : () async {
                        final nombre = nombreCtrl.text.trim();
                        if (nombre.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El nombre del ejercicio es obligatorio')),
                          );
                          return;
                        }

                        setDialogState(() => guardando = true);

                        bool ok = false;
                        if (esEdicion) {
                          ok = await _ejercicioService.actualizarEjercicioSocio(
                            idEjercicio: item.idEjercicio,
                            nombre: nombre,
                            grupoMuscular: selectedGrupo,
                            dificultad: selectedDificultad,
                            descripcion: descCtrl.text.trim(),
                          );
                        } else {
                          final res = await _ejercicioService.crearEjercicioSocio(
                            nombre: nombre,
                            grupoMuscular: selectedGrupo,
                            dificultad: selectedDificultad,
                            descripcion: descCtrl.text.trim(),
                          );
                          ok = res != null;
                        }

                        if (!context.mounted) return;
                        Navigator.of(dialogCtx).pop();

                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(esEdicion
                                  ? '¡Ejercicio actualizado exitosamente!'
                                  : '¡Ejercicio propio creado exitosamente!'),
                              backgroundColor: const Color(0xFF1B2E15),
                            ),
                          );
                          _cargarEjercicios();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al guardar el ejercicio'),
                              backgroundColor: Color(0xFF4A1515),
                            ),
                          );
                        }
                      },
                child: guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        esEdicion ? 'Actualizar' : 'Guardar',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarEliminar(EjercicioModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1B),
        title: const Text('Eliminar Ejercicio Propio', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${item.nombre}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Color(0xFFCCCCCC)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await _ejercicioService.eliminarEjercicioSocio(item.idEjercicio);
              if (!mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ejercicio "${item.nombre}" eliminado'),
                    backgroundColor: const Color(0xFF1B2E15),
                  ),
                );
                _cargarEjercicios();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo eliminar el ejercicio'),
                    backgroundColor: Color(0xFF4A1515),
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int countTotal = _ejercicios.length;
    final int countGym = _ejercicios.where((e) => !e.esPropio).length;
    final int countPropios = _ejercicios.where((e) => e.esPropio).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Biblioteca de Ejercicios',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF7DE610), size: 26),
              tooltip: 'Nuevo Ejercicio Propio',
              onPressed: () => _abrirDialogoCrearEditar(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF7DE610),
          backgroundColor: const Color(0xFF1B1B1B),
          onRefresh: _cargarEjercicios,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // 1. Tarjetas de métricas
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'TOTAL',
                      value: '$countTotal',
                      icon: Icons.fitness_center_rounded,
                      color: const Color(0xFF7DE610),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'DEL GIMNASIO',
                      value: '$countGym',
                      icon: Icons.apartment_rounded,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'MIS EJERCICIOS',
                      value: '$countPropios',
                      icon: Icons.person_rounded,
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Barra de búsqueda
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF262626)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar ejercicio por nombre...',
                    hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8E8E93), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Color(0xFF8E8E93), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _cargarEjercicios();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _cargarEjercicios();
                  },
                ),
              ),
              const SizedBox(height: 12),

              // 3. Filtro por origen (Todos / Gimnasio / Propio)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Todos ($countTotal)',
                      isSelected: _filtroOrigen == 'todos',
                      onTap: () {
                        setState(() => _filtroOrigen = 'todos');
                        _cargarEjercicios();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Gimnasio ($countGym)',
                      isSelected: _filtroOrigen == 'gimnasio',
                      onTap: () {
                        setState(() => _filtroOrigen = 'gimnasio');
                        _cargarEjercicios();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Mis Ejercicios ($countPropios)',
                      isSelected: _filtroOrigen == 'propio',
                      onTap: () {
                        setState(() => _filtroOrigen = 'propio');
                        _cargarEjercicios();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 4. Filtro por grupo muscular
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _gruposMusculares.map((grupo) {
                    final isSelected = _filtroGrupo.toLowerCase() == grupo.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          grupo == 'todos' ? 'Todos los grupos' : grupo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : const Color(0xFF999999),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF7DE610),
                        backgroundColor: const Color(0xFF1B1B1B),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF282828),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filtroGrupo = grupo);
                            _cargarEjercicios();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Lista de ejercicios
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF7DE610)),
                  ),
                )
              else if (_ejercicios.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF262626)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center_rounded, color: Color(0xFF555555), size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'No se encontraron ejercicios',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Probá ajustando la búsqueda o creá tu propio ejercicio personalizado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7DE610),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _abrirDialogoCrearEditar(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Crear Ejercicio Propio', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              else
                ..._ejercicios.map((ej) => _buildEjercicioCard(ej)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7DE610),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear Ejercicio', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _abrirDialogoCrearEditar(),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF242424)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF282828),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFFCCCCCC),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEjercicioCard(EjercicioModel ej) {
    final bool esPropio = ej.esPropio;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esPropio
              ? const Color(0xFFA855F7).withValues(alpha: 0.3)
              : const Color(0xFF242424),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del ejercicio: Nombre + Badges de origen
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ej.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge de Origen
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: esPropio
                      ? const Color(0xFFA855F7).withValues(alpha: 0.15)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: esPropio
                        ? const Color(0xFFA855F7).withValues(alpha: 0.4)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      esPropio ? Icons.person_rounded : Icons.apartment_rounded,
                      size: 11,
                      color: esPropio ? const Color(0xFFA855F7) : const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      esPropio ? 'Mi Ejercicio' : 'Gimnasio',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: esPropio ? const Color(0xFFA855F7) : const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chips de Grupo Muscular y Dificultad
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ej.grupoMuscular ?? 'General',
                  style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ej.dificultad ?? 'Intermedia',
                  style: const TextStyle(color: Color(0xFF7DE610), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          if (ej.descripcion != null && ej.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              ej.descripcion!,
              style: const TextStyle(color: Color(0xFF999999), fontSize: 12, height: 1.3),
            ),
          ],

          // Acciones de edición y eliminación si es propio
          if (ej.puedeEditar || ej.puedeEliminar) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF262626), height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ej.puedeEditar)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      foregroundColor: const Color(0xFFCCCCCC),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Editar', style: TextStyle(fontSize: 12)),
                    onPressed: () => _abrirDialogoCrearEditar(ej),
                  ),
                if (ej.puedeEliminar)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      foregroundColor: const Color(0xFFEF4444),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 15),
                    label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                    onPressed: () => _confirmarEliminar(ej),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
