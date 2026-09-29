import 'package:flutter/material.dart';
import '../../../models/rutina_model.dart';
import '../../../models/socio_model.dart';
import '../../../services/rutina_service.dart';
import '../../../services/socio_service.dart';
import '../../../theme/app_theme.dart';
import 'detalle_rutina_screen.dart';

class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  final RutinaService _rutinaService = RutinaService();
  final SocioService _socioService = SocioService();
  final TextEditingController _searchController = TextEditingController();

  List<RutinaModel> _rutinas = [];
  bool _isLoading = true;
  String _selectedFiltro = 'todos';

  @override
  void initState() {
    super.initState();
    _cargarRutinas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarRutinas() async {
    setState(() => _isLoading = true);

    final lista = await _rutinaService.getRutinas(
      search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      estado: _selectedFiltro != 'todos' ? _selectedFiltro : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _rutinas = lista;
    });
  }

  void _showCrearRutinaDialog() async {
    final sociosRes = await _socioService.getSocios(limit: 50);
    if (!mounted) return;

    final socios = (sociosRes['socios'] as List<SocioModel>?) ?? [];
    if (socios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay socios registrados para asignarles rutinas.'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    dynamic selectedSocioId = socios.first.idSocio;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161D21),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(Icons.splitscreen_rounded, color: Color(0xFF00E676)),
                SizedBox(width: 10),
                Text('Nueva Rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOMBRE DE LA RUTINA', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: Hipertrofia Pecho y Bíceps',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('SOCIO ASIGNADO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F292E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: selectedSocioId,
                        dropdownColor: const Color(0xFF1F292E),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: socios
                            .map((s) => DropdownMenuItem(
                                  value: s.idSocio,
                                  child: Text('${s.nombreCompleto} (DNI ${s.dni})'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedSocioId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('DESCRIPCIÓN / OBJETIVO (OPCIONAL)', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: 4 días semanales, enfocado en volumen...',
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

                        final socioIdParsed = int.tryParse(selectedSocioId.toString()) ?? 1;

                        setDialogState(() => isSaving = true);

                        final ok = await _rutinaService.createRutina(
                          nombre: nombre,
                          descripcion: descCtrl.text,
                          idSocio: socioIdParsed,
                        );

                        if (!context.mounted) return;
                        setDialogState(() => isSaving = false);
                        Navigator.pop(context);

                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rutina creada exitosamente.'),
                              backgroundColor: Color(0xFF1B5E20),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _cargarRutinas();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al crear la rutina.'),
                              backgroundColor: Color(0xFFB71C1C),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Crear Rutina', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarEliminar(RutinaModel r) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161D21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Rutina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas eliminar la rutina "${r.nombre}"?', style: const TextStyle(color: Color(0xFFB0BEC5))),
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
              Navigator.pop(context);
              final ok = await _rutinaService.deleteRutina(r.idRutina);
              if (!mounted) return;
              if (ok) {
                _cargarRutinas();
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
          'Rutinas de Entrenamiento',
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            tooltip: 'Actualizar',
            onPressed: _cargarRutinas,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Rutina', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showCrearRutinaDialog,
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
                  hintText: 'Buscar por nombre de rutina...',
                  hintStyle: const TextStyle(color: Color(0xFF7A8B94), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E676), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF7A8B94), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _cargarRutinas();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _cargarRutinas(),
              ),
            ),
          ),

          // Filtros de Estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('todos', 'Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('activo', 'Activas'),
                const SizedBox(width: 8),
                _buildFilterChip('inactivo', 'Inactivas'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Lista de Rutinas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
                : _rutinas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.splitscreen_rounded, color: Color(0xFF7A8B94), size: 48),
                            const SizedBox(height: 12),
                            const Text('No se encontraron rutinas.', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 6),
                            const Text('Crea una rutina personalizada para tus socios.', style: TextStyle(color: Color(0xFF7A8B94), fontSize: 13)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF00E676),
                        backgroundColor: const Color(0xFF161E22),
                        onRefresh: _cargarRutinas,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: _rutinas.length,
                          itemBuilder: (context, index) {
                            final r = _rutinas[index];
                            return _buildRutinaCard(r);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFiltro == value;
    return ChoiceChip(
      label: Text(label),
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
      onSelected: (val) {
        if (val) {
          setState(() => _selectedFiltro = value);
          _cargarRutinas();
        }
      },
    );
  }

  Widget _buildRutinaCard(RutinaModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243037)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleRutinaScreen(idRutina: r.idRutina),
              ),
            ).then((_) => _cargarRutinas());
          },
          child: Padding(
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: r.isActiva
                            ? const Color(0xFF00E676).withValues(alpha: 0.15)
                            : const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.estado.toUpperCase(),
                        style: TextStyle(
                          color: r.isActiva ? const Color(0xFF00E676) : const Color(0xFFEF4444),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF243037)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, color: Color(0xFF00E676), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          r.socioNombre ?? 'Sin socio asignado',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF243037),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${r.ejercicios.length} ejercicios',
                            style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF7A8B94), size: 18),
                          tooltip: 'Eliminar rutina',
                          onPressed: () => _confirmarEliminar(r),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
