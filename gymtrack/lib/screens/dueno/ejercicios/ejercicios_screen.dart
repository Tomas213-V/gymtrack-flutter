import 'package:flutter/material.dart';
import '../../../models/ejercicio_model.dart';
import '../../../services/ejercicio_service.dart';
import '../../../theme/app_theme.dart';

class EjerciciosScreen extends StatefulWidget {
  const EjerciciosScreen({super.key});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen> {
  final EjercicioService _ejercicioService = EjercicioService();
  final TextEditingController _searchController = TextEditingController();

  List<EjercicioModel> _ejercicios = [];
  bool _isLoading = true;
  String _selectedGrupo = 'Todos';

  final List<String> _gruposMusculares = [
    'Todos',
    'Pecho',
    'Espalda',
    'Piernas',
    'Brazos',
    'Hombros',
    'Abdominales',
    'Cardio',
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

    final lista = await _ejercicioService.getEjercicios(
      grupoMuscular: _selectedGrupo != 'Todos' ? _selectedGrupo : null,
      search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _ejercicios = lista;
    });
  }

  void _showFormularioDialog({EjercicioModel? ejercicio}) {
    final nombreCtrl = TextEditingController(text: ejercicio?.nombre ?? '');
    final descCtrl = TextEditingController(text: ejercicio?.descripcion ?? '');
    String selectedGrupo = ejercicio?.grupoMuscular ?? 'Pecho';
    String selectedDificultad = ejercicio?.dificultad ?? 'Intermedio';
    bool isSaving = false;

    final dificultades = ['Principiante', 'Intermedio', 'Avanzado'];
    final grupos = ['Pecho', 'Espalda', 'Piernas', 'Brazos', 'Hombros', 'Abdominales', 'Cardio', 'General'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161D21),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Icon(
                  ejercicio != null ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                  color: const Color(0xFF00E676),
                ),
                const SizedBox(width: 10),
                Text(
                  ejercicio != null ? 'Editar Ejercicio' : 'Nuevo Ejercicio',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOMBRE DEL EJERCICIO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: Press de banca plano',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('GRUPO MUSCULAR', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F292E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: grupos.contains(selectedGrupo) ? selectedGrupo : grupos.first,
                        dropdownColor: const Color(0xFF1F292E),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: grupos
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedGrupo = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('DIFICULTAD', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F292E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dificultades.contains(selectedDificultad) ? selectedDificultad : dificultades[1],
                        dropdownColor: const Color(0xFF1F292E),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: dificultades
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedDificultad = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('DESCRIPCIÓN / TÉCNICA (OPCIONAL)', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Indicaciones posturales y respiración...',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8A98A0))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        final nombre = nombreCtrl.text.trim();
                        if (nombre.isEmpty) return;

                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        setDialogState(() => isSaving = true);

                        bool ok;
                        if (ejercicio != null) {
                          ok = await _ejercicioService.updateEjercicio(
                            idEjercicio: ejercicio.idEjercicio,
                            nombre: nombre,
                            grupoMuscular: selectedGrupo,
                            dificultad: selectedDificultad,
                            descripcion: descCtrl.text,
                          );
                        } else {
                          ok = await _ejercicioService.createEjercicio(
                            nombre: nombre,
                            grupoMuscular: selectedGrupo,
                            dificultad: selectedDificultad,
                            descripcion: descCtrl.text,
                          );
                        }

                        if (!mounted) return;

                        navigator.pop();

                        if (ok) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(ejercicio != null
                                  ? 'Ejercicio actualizado.'
                                  : 'Ejercicio agregado al catálogo.'),
                              backgroundColor: const Color(0xFF1B5E20),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _cargarEjercicios();
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Error al guardar el ejercicio.'),
                              backgroundColor: Color(0xFFB71C1C),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        ejercicio != null ? 'Guardar' : 'Crear',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarEliminar(EjercicioModel e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161D21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Ejercicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas eliminar "${e.nombre}" del catálogo?', style: const TextStyle(color: Color(0xFFB0BEC5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8A98A0))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final ok = await _ejercicioService.deleteEjercicio(e.idEjercicio);
              if (!mounted) return;

              if (ok) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Ejercicio eliminado.'), backgroundColor: Color(0xFF1B5E20), behavior: SnackBarBehavior.floating),
                );
                _cargarEjercicios();
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No se pudo eliminar el ejercicio.'), backgroundColor: Color(0xFFB71C1C), behavior: SnackBarBehavior.floating),
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF12181B),
        elevation: 0,
        title: const Text(
          'Catálogo de Ejercicios',
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            tooltip: 'Actualizar',
            onPressed: _cargarEjercicios,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Ejercicio', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showFormularioDialog(),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF161E22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF243037)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar ejercicio por nombre...',
                  hintStyle: const TextStyle(color: Color(0xFF7A8B94), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E676), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF7A8B94), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _cargarEjercicios();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _cargarEjercicios(),
              ),
            ),
          ),

          // Chips de grupos musculares
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _gruposMusculares.length,
              itemBuilder: (context, index) {
                final grupo = _gruposMusculares[index];
                final isSelected = _selectedGrupo == grupo;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: FilterChip(
                    label: Text(grupo),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00E676),
                    backgroundColor: const Color(0xFF161E22),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF00E676) : const Color(0xFF243037),
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedGrupo = grupo;
                      });
                      _cargarEjercicios();
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // Lista de Ejercicios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
                : _ejercicios.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fitness_center_outlined, color: Color(0xFF7A8B94), size: 48),
                            const SizedBox(height: 12),
                            const Text('No se encontraron ejercicios.', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 6),
                            const Text('Podés agregar uno presionando el botón "+".', style: TextStyle(color: Color(0xFF7A8B94), fontSize: 13)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF00E676),
                        backgroundColor: const Color(0xFF161E22),
                        onRefresh: _cargarEjercicios,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: _ejercicios.length,
                          itemBuilder: (context, index) {
                            final ej = _ejercicios[index];
                            return _buildEjercicioCard(ej);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEjercicioCard(EjercicioModel ej) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243037)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: Color(0xFF00E676), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ej.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (ej.grupoMuscular != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF243037),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ej.grupoMuscular!,
                          style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (ej.dificultad != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF243037),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ej.dificultad!,
                          style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 11),
                        ),
                      ),
                  ],
                ),
                if (ej.descripcion != null && ej.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    ej.descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF7A8B94), size: 20),
            color: const Color(0xFF1E282D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Editar', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 10),
                    Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'editar') {
                _showFormularioDialog(ejercicio: ej);
              } else if (val == 'eliminar') {
                _confirmarEliminar(ej);
              }
            },
          ),
        ],
      ),
    );
  }
}
