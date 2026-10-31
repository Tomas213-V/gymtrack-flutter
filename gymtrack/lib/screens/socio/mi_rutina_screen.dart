import 'package:flutter/material.dart';
import '../../mock/socio_mock_data.dart';
import '../../models/rutina_model.dart' as backend_rutina;
import '../../models/socio_mock_models.dart' as mock_models;
import '../../services/auth_service.dart';
import '../../services/rutina_service.dart';
import '../../theme/app_theme.dart';
import 'detalle_ejercicio_screen.dart';

class MiRutinaScreen extends StatefulWidget {
  final bool showBackButton;
  final int initialTab;

  const MiRutinaScreen({
    super.key,
    this.showBackButton = false,
    this.initialTab = 0,
  });

  @override
  State<MiRutinaScreen> createState() => _MiRutinaScreenState();
}

class _MiRutinaScreenState extends State<MiRutinaScreen> {
  final RutinaService _rutinaService = RutinaService();

  late int _selectedTab; // 0: Rutinas del Gimnasio, 1: Rutinas Propias
  List<backend_rutina.RutinaModel> _rutinasGym = [];
  List<backend_rutina.RutinaModel> _rutinasPropias = [];
  bool _isLoadingGym = false;
  bool _isLoadingPropias = false;

  final Set<String> _ejerciciosCompletados = {};
  final Set<int> _expandedRutinas = {};

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _cargarProgramasGym();
    _cargarMisRutinas();
  }

  Future<void> _cargarProgramasGym() async {
    setState(() => _isLoadingGym = true);
    final lista = await _rutinaService.fetchRutinasOfrecidasGym();
    if (!mounted) return;
    setState(() {
      _isLoadingGym = false;
      _rutinasGym = lista;
    });
  }

  Future<void> _cargarMisRutinas() async {
    setState(() => _isLoadingPropias = true);
    final currentUser = AuthService().currentUser;
    final idSocio = currentUser?.idUsuario;
    final lista = await _rutinaService.getRutinas(idSocio: idSocio);
    if (!mounted) return;
    setState(() {
      _isLoadingPropias = false;
      _rutinasPropias = lista;
    });
  }

  mock_models.EjercicioModel _toMockEjercicio(backend_rutina.RutinaEjercicioModel re) {
    final ej = re.ejercicio;
    final idStr = (re.idRutinaEjercicio ?? re.idEjercicio).toString();
    final isDone = _ejerciciosCompletados.contains(idStr);
    return mock_models.EjercicioModel(
      id: idStr,
      nombre: ej?.nombre ?? 'Ejercicio #${re.idEjercicio}',
      grupoMuscular: ej?.grupoMuscular ?? 'Pecho',
      categoria: 'Fuerza',
      series: re.series,
      repeticiones: re.repeticiones,
      peso: re.peso != null && re.peso! > 0 ? '${re.peso!.toStringAsFixed(0)} kg' : 'Sin peso',
      descanso: re.descanso != null ? '${re.descanso} seg' : '60 seg',
      instrucciones: ej?.descripcion ?? 'Realizar el movimiento con técnica estricta y respiración controlada.',
      completado: isDone,
    );
  }

  Future<void> _adoptarRutina(backend_rutina.RutinaModel rutina) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Adoptar Rutina del Gimnasio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas adoptar "${rutina.nombre}" como tu rutina activa personal?', style: const TextStyle(color: Color(0xFFB0BEC5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7DE610), foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Adoptar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final currentUser = AuthService().currentUser;
    final res = await _rutinaService.adoptarRutinaGym(
      idPlantilla: rutina.idRutina,
      idSocio: currentUser?.idUsuario,
      nombrePersonalizado: rutina.nombre,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']?.toString() ?? 'Rutina adoptada con éxito.'),
        backgroundColor: res['success'] == true ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (res['success'] == true) {
      await _cargarMisRutinas();
      setState(() => _selectedTab = 1);
    }
  }

  Future<void> _activarRutina(int idRutina) async {
    final ok = await _rutinaService.activarRutina(idRutina);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Rutina marcada como activa!'),
          backgroundColor: Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarMisRutinas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo activar la rutina.'),
          backgroundColor: Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _eliminarRutina(int idRutina, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Eliminar Rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar la rutina "$nombre"?', style: const TextStyle(color: Color(0xFFB0BEC5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await _rutinaService.deleteRutina(idRutina);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutina eliminada.'),
          backgroundColor: Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarMisRutinas();
    }
  }

  void _mostrarDialogCrearRutina() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String diasSeleccionados = 'Lunes, Miércoles, Viernes';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Color(0xFF7DE610)),
              SizedBox(width: 8),
              Text('Crear Rutina Propia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre de la rutina *', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ej. Mi Rutina de Hipertrofia',
                    hintStyle: const TextStyle(color: Color(0xFF6E6E73)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Objetivo o descripción', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ej. Fortalecimiento del tren superior y core.',
                    hintStyle: const TextStyle(color: Color(0xFF6E6E73)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Frecuencia semanal', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    'Lunes, Miércoles, Viernes',
                    'Lunes a Viernes',
                    'Martes, Jueves, Sábado',
                    'Fin de semana',
                  ].map((op) {
                    final sel = diasSeleccionados == op;
                    return ChoiceChip(
                      label: Text(op, style: TextStyle(color: sel ? Colors.black : Colors.white, fontSize: 11, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                      selected: sel,
                      selectedColor: const Color(0xFF7DE610),
                      backgroundColor: const Color(0xFF2A2A2A),
                      onSelected: (_) => setDialogState(() => diasSeleccionados = op),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7DE610), foregroundColor: Colors.black),
              onPressed: () async {
                final nombre = nameCtrl.text.trim();
                if (nombre.isEmpty) return;
                Navigator.pop(ctx);

                final currentUser = AuthService().currentUser;
                final ok = await _rutinaService.createRutina(
                  nombre: nombre,
                  descripcion: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                  idSocio: currentUser?.idUsuario ?? 1,
                  dias: diasSeleccionados,
                );

                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡Rutina "$nombre" creada con éxito!'),
                      backgroundColor: const Color(0xFF1B5E20),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _cargarMisRutinas();
                }
              },
              child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Mi Rutina',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Actualizar',
            onPressed: () {
              _cargarProgramasGym();
              _cargarMisRutinas();
            },
          ),
          if (widget.showBackButton)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
              tooltip: 'Cerrar',
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de pestaña estilo píldora
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D21),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF243037)),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Rutinas del Gimnasio', 0),
                    _buildTabButton('Rutinas Propias', 1),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _selectedTab == 0
                  ? _buildRutinasGymTab()
                  : _buildRutinasPropiasTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7DE610) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF8E8E93),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. PESTAÑA: RUTINAS DEL GIMNASIO (Asociadas al gimnasio)
  // ===========================================================================
  Widget _buildRutinasGymTab() {
    if (_isLoadingGym) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7DE610)));
    }

    return RefreshIndicator(
      color: const Color(0xFF7DE610),
      backgroundColor: const Color(0xFF1B1B1B),
      onRefresh: _cargarProgramasGym,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Banner informativo oficial
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF152219),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF7DE610).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DE610).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: Color(0xFF7DE610), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rutinas asociadas al gimnasio',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Programas oficiales diseñados por los entrenadores del gimnasio. Puedes adoptarlos y usarlos como tu rutina activa.',
                        style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_rutinasGym.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fitness_center_rounded, color: Color(0xFF6E6E73), size: 48),
                    const SizedBox(height: 12),
                    const Text('No hay programas oficiales disponibles.', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Tu gimnasio publicará programas de entrenamiento aquí.', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ..._rutinasGym.map((r) => _buildGymRoutineCard(r)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGymRoutineCard(backend_rutina.RutinaModel r) {
    final isExpanded = _expandedRutinas.contains(r.idRutina);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF282828)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7DE610).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OFICIAL GYM',
                        style: TextStyle(color: Color(0xFF7DE610), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (r.descripcion != null && r.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.descripcion!,
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (r.dificultad != null && r.dificultad!.isNotEmpty)
                      _buildChip(Icons.speed_rounded, r.dificultad!),
                    if (r.duracion != null && r.duracion!.isNotEmpty)
                      _buildChip(Icons.timer_outlined, r.duracion!),
                    if (r.dias != null && r.dias!.isNotEmpty)
                      _buildChip(Icons.calendar_today_rounded, r.dias!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.list_alt_rounded, color: Color(0xFF7DE610), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${r.ejercicios.length} ejercicios incluidos',
                      style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7DE610),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18),
                      label: Text(isExpanded ? 'Ocultar ejercicios' : 'Ver ejercicios', style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedRutinas.remove(r.idRutina);
                          } else {
                            _expandedRutinas.add(r.idRutina);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ejercicios desplegables
          if (isExpanded && r.ejercicios.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                border: Border(top: BorderSide(color: Color(0xFF242424))),
              ),
              child: Column(
                children: r.ejercicios.map((re) {
                  final mockEj = _toMockEjercicio(re);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center_rounded, color: Color(0xFF7DE610), size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mockEj.nombre, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                '${mockEj.series} series × ${mockEj.repeticiones} reps • ${mockEj.peso} • ${mockEj.descanso}',
                                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF7DE610), size: 18),
                          tooltip: 'Ver detalle del ejercicio',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetalleEjercicioScreen(
                                  ejercicio: mockEj,
                                  onStatusChanged: () => setState(() {}),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                label: const Text('Comenzar / Adoptar Rutina', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DE610),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onPressed: () => _adoptarRutina(r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. PESTAÑA: RUTINAS PROPIAS (Propias del socio)
  // ===========================================================================
  Widget _buildRutinasPropiasTab() {
    if (_isLoadingPropias) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7DE610)));
    }

    // Identificar rutina activa
    final backend_rutina.RutinaModel activa = _rutinasPropias.firstWhere(
      (r) => r.isActiva,
      orElse: () => _rutinasPropias.isNotEmpty ? _rutinasPropias.first : backend_rutina.RutinaModel(idRutina: 0, nombre: '', estado: 'inactivo'),
    );
    final tieneActiva = activa.idRutina != 0;
    final otrasRutinas = _rutinasPropias.where((r) => r.idRutina != activa.idRutina).toList();

    return RefreshIndicator(
      color: const Color(0xFF7DE610),
      backgroundColor: const Color(0xFF1B1B1B),
      onRefresh: _cargarMisRutinas,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Cabecera con botón "+ Crear Rutina Propia"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rutinas propias del socio',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tus rutinas personalizadas y adoptadas',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11.5),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Crear Propia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7DE610),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _mostrarDialogCrearRutina,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Tarjeta destacada: Rutina Activa
          if (tieneActiva) ...[
            _buildRutinaActivaHeroCard(activa),
            const SizedBox(height: 22),
          ],

          // 2. Otras rutinas propias
          if (otrasRutinas.isNotEmpty) ...[
            Text(
              'Otras rutinas propias (${otrasRutinas.length})',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...otrasRutinas.map((r) => _buildRutinaPropiaCard(r)),
          ],

          if (!tieneActiva && otrasRutinas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border_rounded, color: Color(0xFF6E6E73), size: 48),
                    const SizedBox(height: 12),
                    const Text('Aún no tienes rutinas guardadas.', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Crea una propia o adopta una en "Rutinas del Gimnasio".', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRutinaActivaHeroCard(backend_rutina.RutinaModel r) {
    final diasActivos = _diasActivosFromDias(r.dias);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7DE610).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7DE610).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7DE610),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RUTINA ACTIVA',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              if (r.duracion != null && r.duracion!.isNotEmpty)
                Text(
                  r.duracion!,
                  style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Asignada por: Prof. Martín',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DÍAS DE ENTRENAMIENTO',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['L', 'M', 'X', 'J', 'V'].map((dia) {
              final isActive = diasActivos.contains(dia);
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF7DE610) : const Color(0xFF282828),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dia,
                    style: TextStyle(
                      color: isActive ? Colors.black : const Color(0xFF8E8E93),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Sección Ejercicios de hoy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ejercicios de hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${r.ejercicios.length} ejercicios',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de ejercicios interactivos
          if (r.ejercicios.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Aún no hay ejercicios asociados a esta rutina.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
            )
          else
            ...r.ejercicios.map((re) {
              final mockEj = _toMockEjercicio(re);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildExerciseCard(mockEj, re),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRutinaPropiaCard(backend_rutina.RutinaModel r) {
    final isExpanded = _expandedRutinas.contains(r.idRutina);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF282828)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E8E93).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'INACTIVA',
                        style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (r.descripcion != null && r.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.descripcion!,
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (r.dias != null && r.dias!.isNotEmpty)
                      _buildChip(Icons.calendar_today_rounded, r.dias!),
                    _buildChip(Icons.list_alt_rounded, '${r.ejercicios.length} ejercicios'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7DE610),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18),
                      label: Text(isExpanded ? 'Ocultar ejercicios' : 'Ver ejercicios', style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedRutinas.remove(r.idRutina);
                          } else {
                            _expandedRutinas.add(r.idRutina);
                          }
                        });
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE57373), size: 20),
                      tooltip: 'Eliminar rutina',
                      onPressed: () => _eliminarRutina(r.idRutina, r.nombre),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ejercicios desplegables
          if (isExpanded && r.ejercicios.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                border: Border(top: BorderSide(color: Color(0xFF242424))),
              ),
              child: Column(
                children: r.ejercicios.map((re) {
                  final mockEj = _toMockEjercicio(re);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center_rounded, color: Color(0xFF7DE610), size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mockEj.nombre, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                '${mockEj.series} series × ${mockEj.repeticiones} reps • ${mockEj.peso}',
                                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF7DE610), size: 18),
                          tooltip: 'Ver detalle del ejercicio',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetalleEjercicioScreen(
                                  ejercicio: mockEj,
                                  onStatusChanged: () => setState(() {}),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF7DE610), size: 18),
                label: const Text('Establecer como Rutina Activa', style: TextStyle(color: Color(0xFF7DE610), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7DE610)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => _activarRutina(r.idRutina),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(mock_models.EjercicioModel ej, backend_rutina.RutinaEjercicioModel re) {
    final idStr = (re.idRutinaEjercicio ?? re.idEjercicio).toString();
    final isDone = _ejerciciosCompletados.contains(idStr);

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetalleEjercicioScreen(
              ejercicio: ej,
              onStatusChanged: () {
                setState(() {
                  if (ej.completado) {
                    _ejerciciosCompletados.add(idStr);
                  } else {
                    _ejerciciosCompletados.remove(idStr);
                  }
                });
              },
            ),
          ),
        );
        setState(() {});
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone ? const Color(0xFF7DE610).withValues(alpha: 0.4) : const Color(0xFF2E2E2E),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isDone) {
                    _ejerciciosCompletados.remove(idStr);
                    ej.completado = false;
                  } else {
                    _ejerciciosCompletados.add(idStr);
                    ej.completado = true;
                  }
                  SocioMockData().toggleEjercicioCompletado(idStr);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF7DE610) : Colors.transparent,
                  border: Border.all(color: isDone ? const Color(0xFF7DE610) : const Color(0xFF6E6E73), width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ej.nombre,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF7DE610),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ej.series} series × ${ej.repeticiones} reps • ${ej.peso}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6E6E73),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF7DE610)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11)),
        ],
      ),
    );
  }

  List<String> _diasActivosFromDias(String? diasStr) {
    if (diasStr == null || diasStr.isEmpty) return ['L', 'X', 'V'];
    final lower = diasStr.toLowerCase();
    final list = <String>[];
    if (lower.contains('lun')) list.add('L');
    if (lower.contains('mar')) list.add('M');
    if (lower.contains('mié') || lower.contains('mie')) list.add('X');
    if (lower.contains('jue')) list.add('J');
    if (lower.contains('vie')) list.add('V');
    if (lower.contains('sáb') || lower.contains('sab')) list.add('S');
    if (lower.contains('dom')) list.add('D');
    return list.isEmpty ? ['L', 'X', 'V'] : list;
  }
}
