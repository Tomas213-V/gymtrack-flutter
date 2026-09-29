import 'package:flutter/material.dart';
import '../../../models/rutina_model.dart';

import '../../../services/ejercicio_service.dart';
import '../../../services/rutina_service.dart';
import '../../../theme/app_theme.dart';

class DetalleRutinaScreen extends StatefulWidget {
  final int idRutina;

  const DetalleRutinaScreen({super.key, required this.idRutina});

  @override
  State<DetalleRutinaScreen> createState() => _DetalleRutinaScreenState();
}

class _DetalleRutinaScreenState extends State<DetalleRutinaScreen> {
  final RutinaService _rutinaService = RutinaService();
  final EjercicioService _ejercicioService = EjercicioService();

  RutinaModel? _rutina;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarRutina();
  }

  Future<void> _cargarRutina() async {
    setState(() => _isLoading = true);
    final data = await _rutinaService.getRutinaById(widget.idRutina);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _rutina = data;
    });
  }

  void _showAgregarEjercicioDialog() async {
    final ejerciciosDisponibles = await _ejercicioService.getEjercicios(limit: 100);
    if (!mounted) return;

    if (ejerciciosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay ejercicios en el catálogo. Primero crea ejercicios en el catálogo.'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int selectedEjercicioId = ejerciciosDisponibles.first.idEjercicio;
    final seriesCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '12');
    final pesoCtrl = TextEditingController(text: '20');
    final descansoCtrl = TextEditingController(text: '60');
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
                Icon(Icons.fitness_center_rounded, color: Color(0xFF00E676)),
                SizedBox(width: 10),
                Text('Agregar Ejercicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECCIONAR EJERCICIO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F292E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedEjercicioId,
                        dropdownColor: const Color(0xFF1F292E),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: ejerciciosDisponibles
                            .map((e) => DropdownMenuItem(
                                  value: e.idEjercicio,
                                  child: Text('${e.nombre} (${e.grupoMuscular ?? "General"})'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedEjercicioId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SERIES', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: seriesCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1F292E),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('REPETICIONES', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: repsCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1F292E),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PESO (KG)', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: pesoCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1F292E),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DESCANSO (SEG)', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: descansoCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1F292E),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        setDialogState(() => isSaving = true);
                        final ok = await _rutinaService.addEjercicioToRutina(
                          idRutina: widget.idRutina,
                          idEjercicio: selectedEjercicioId,
                          series: int.tryParse(seriesCtrl.text) ?? 3,
                          repeticiones: int.tryParse(repsCtrl.text) ?? 10,
                          peso: double.tryParse(pesoCtrl.text),
                          descanso: int.tryParse(descansoCtrl.text),
                        );

                        if (!context.mounted) return;
                        setDialogState(() => isSaving = false);
                        Navigator.pop(context);

                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ejercicio asignado a la rutina.'),
                              backgroundColor: Color(0xFF1B5E20),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _cargarRutina();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al asignar el ejercicio.'),
                              backgroundColor: Color(0xFFB71C1C),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Agregar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _quitarEjercicio(RutinaEjercicioModel ej) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161D21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quitar Ejercicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas quitar este ejercicio de la rutina?', style: const TextStyle(color: Color(0xFFB0BEC5))),
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
              final ok = await _rutinaService.removeEjercicioFromRutina(
                idRutina: widget.idRutina,
                idEjercicio: ej.idEjercicio,
              );
              if (!mounted) return;
              if (ok) {
                _cargarRutina();
              }
            },
            child: const Text('Quitar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: Text(
          _rutina?.nombre ?? 'Detalle de Rutina',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            onPressed: _cargarRutina,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Ejercicio', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAgregarEjercicioDialog,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
    }

    if (_rutina == null) {
      return const Center(
        child: Text('No se pudo encontrar la rutina.', style: TextStyle(color: Colors.white)),
      );
    }

    final r = _rutina!;

    return RefreshIndicator(
      color: const Color(0xFF00E676),
      backgroundColor: const Color(0xFF161E22),
      onRefresh: _cargarRutina,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Tarjeta Principal de la Rutina
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161E22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF243037)),
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
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.isActiva
                            ? const Color(0xFF00E676).withValues(alpha: 0.15)
                            : const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        r.estado.toUpperCase(),
                        style: TextStyle(
                          color: r.isActiva ? const Color(0xFF00E676) : const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (r.descripcion != null && r.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    r.descripcion!,
                    style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF243037)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, color: Color(0xFF00E676), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Socio asignado: ${r.socioNombre ?? "Sin asignar"}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (r.fechaInicio != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Color(0xFF8A98A0), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Periodo: ${r.fechaInicio} ${r.fechaFin != null ? "al ${r.fechaFin}" : ""}',
                        style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Título de Ejercicios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ejercicios en la rutina (${r.ejercicios.length})',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (r.ejercicios.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF161E22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF243037)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center_outlined, color: Color(0xFF7A8B94), size: 40),
                    const SizedBox(height: 12),
                    const Text('Esta rutina aún no tiene ejercicios.', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 6),
                    const Text('Tocá el botón "Agregar Ejercicio" para sumar uno.', style: TextStyle(color: Color(0xFF8A98A0), fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ...r.ejercicios.map((ej) => _buildEjercicioRow(ej)),
        ],
      ),
    );
  }

  Widget _buildEjercicioRow(RutinaEjercicioModel ej) {
    final nombre = ej.ejercicio?.nombre ?? 'Ejercicio #${ej.idEjercicio}';
    final grupo = ej.ejercicio?.grupoMuscular;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243037)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center, color: Color(0xFF00E676), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (grupo != null) ...[
                      Text(grupo, style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${ej.series} series × ${ej.repeticiones} reps',
                      style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
                    ),
                    if (ej.peso != null && ej.peso! > 0) ...[
                      const SizedBox(width: 8),
                      Text('• ${ej.peso!.toStringAsFixed(0)} kg', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
            tooltip: 'Quitar de la rutina',
            onPressed: () => _quitarEjercicio(ej),
          ),
        ],
      ),
    );
  }
}
