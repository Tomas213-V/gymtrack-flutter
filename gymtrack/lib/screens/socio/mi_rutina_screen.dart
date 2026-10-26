import 'package:flutter/material.dart';
import '../../mock/socio_mock_data.dart';
import '../../models/rutina_model.dart' as backend_rutina;
import '../../models/socio_mock_models.dart';
import '../../services/auth_service.dart';
import '../../services/rutina_service.dart';
import '../../theme/app_theme.dart';
import 'detalle_ejercicio_screen.dart';

class MiRutinaScreen extends StatefulWidget {
  final bool showBackButton;

  const MiRutinaScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<MiRutinaScreen> createState() => _MiRutinaScreenState();
}

class _MiRutinaScreenState extends State<MiRutinaScreen> {
  final _mockData = SocioMockData();
  final RutinaService _rutinaService = RutinaService();

  int _selectedTab = 0; // 0: Mi Rutina, 1: Programas Gym, 2: Mis Rutinas
  List<backend_rutina.RutinaModel> _programasGym = [];
  List<backend_rutina.RutinaModel> _misRutinas = [];
  bool _isLoadingGym = false;
  bool _isLoadingMisRutinas = false;

  @override
  void initState() {
    super.initState();
    _cargarProgramasGym();
    _cargarMisRutinas();
  }

  Future<void> _cargarProgramasGym() async {
    setState(() => _isLoadingGym = true);
    final lista = await _rutinaService.fetchRutinasOfrecidasGym();
    if (!mounted) return;
    setState(() {
      _isLoadingGym = false;
      _programasGym = lista;
    });
  }

  Future<void> _cargarMisRutinas() async {
    setState(() => _isLoadingMisRutinas = true);
    final currentUser = AuthService().currentUser;
    final idSocio = currentUser?.idUsuario;
    final lista = await _rutinaService.getRutinas(idSocio: idSocio);
    if (!mounted) return;
    setState(() {
      _isLoadingMisRutinas = false;
      _misRutinas = lista;
    });
  }

  Future<void> _adoptarRutina(backend_rutina.RutinaModel rutina) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Comenzar Programa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas adoptar "${rutina.nombre}" como una de tus rutinas de entrenamiento?', style: const TextStyle(color: Color(0xFFB0BEC5))),
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
      _cargarMisRutinas();
      setState(() => _selectedTab = 2);
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

  @override
  Widget build(BuildContext context) {
    final rutina = _mockData.rutina;

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
                    _buildTabButton('Rutina Activa', 0),
                    _buildTabButton('Programas Gym', 1),
                    _buildTabButton('Mis Rutinas', 2),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _selectedTab == 0
                  ? _buildMiRutinaTab(rutina)
                  : _selectedTab == 1
                      ? _buildProgramasGymTab()
                      : _buildMisRutinasTab(),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7DE610) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF8E8E93),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // 1. Pestaña: Mi Rutina Activa
  Widget _buildMiRutinaTab(RutinaModel rutina) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Tarjeta de información de la Rutina
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
              Text(
                rutina.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Asignada por: ${rutina.entrenador}',
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
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
                children: rutina.diasSemana.map((dia) {
                  final isActive = rutina.diasActivos.contains(dia);
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
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Sección Ejercicios de hoy
        const Text(
          'Ejercicios de hoy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),

        // Lista de ejercicios
        ...rutina.ejercicios.map((ej) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExerciseCard(ej),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // 2. Pestaña: Programas del Gimnasio
  Widget _buildProgramasGymTab() {
    if (_isLoadingGym) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7DE610)));
    }

    if (_programasGym.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center_rounded, color: Color(0xFF6E6E73), size: 48),
            const SizedBox(height: 12),
            const Text('No hay programas oficiales disponibles.', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Tu gimnasio publicará programas de entrenamiento aquí.', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7DE610),
                foregroundColor: Colors.black,
              ),
              onPressed: _cargarProgramasGym,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF7DE610),
      backgroundColor: const Color(0xFF1B1B1B),
      onRefresh: _cargarProgramasGym,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _programasGym.length,
        itemBuilder: (context, index) {
          final r = _programasGym[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF282828)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.list_alt_rounded, color: Color(0xFF7DE610), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${r.ejercicios.length} ejercicios incluidos',
                      style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
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
              ],
            ),
          );
        },
      ),
    );
  }

  // 3. Pestaña: Mis Rutinas
  Widget _buildMisRutinasTab() {
    if (_isLoadingMisRutinas) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7DE610)));
    }

    if (_misRutinas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border_rounded, color: Color(0xFF6E6E73), size: 48),
            const SizedBox(height: 12),
            const Text('Aún no tienes rutinas guardadas.', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Adopta un programa del gimnasio en la pestaña superior.', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF7DE610),
      backgroundColor: const Color(0xFF1B1B1B),
      onRefresh: _cargarMisRutinas,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _misRutinas.length,
        itemBuilder: (context, index) {
          final r = _misRutinas[index];
          final isActiva = r.isActiva;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isActiva ? const Color(0xFF7DE610).withValues(alpha: 0.5) : const Color(0xFF282828),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActiva
                            ? const Color(0xFF7DE610).withValues(alpha: 0.15)
                            : const Color(0xFF8E8E93).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActiva ? 'ACTIVA' : 'INACTIVA',
                        style: TextStyle(
                          color: isActiva ? const Color(0xFF7DE610) : const Color(0xFF8E8E93),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (r.descripcion != null && r.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.descripcion!,
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  '${r.ejercicios.length} ejercicios registrados',
                  style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
                ),
                if (!isActiva) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF7DE610), size: 18),
                      label: const Text('Establecer como Rutina Activa', style: TextStyle(color: Color(0xFF7DE610), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7DE610)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _activarRutina(r.idRutina),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(EjercicioModel ej) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetalleEjercicioScreen(
              ejercicio: ej,
              onStatusChanged: () {
                setState(() {});
              },
            ),
          ),
        );
        setState(() {});
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ej.completado ? const Color(0xFF7DE610).withValues(alpha: 0.4) : const Color(0xFF282828),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (ej.completado)
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF7DE610),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.black,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: ej.completado ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF7DE610),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ej.resumenCorto,
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
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
