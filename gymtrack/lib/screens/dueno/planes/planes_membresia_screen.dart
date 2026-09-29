import 'package:flutter/material.dart';
import '../../../models/plan_membresia_model.dart';
import '../../../services/plan_membresia_service.dart';
import '../../../theme/app_theme.dart';

class PlanesMembresiaScreen extends StatefulWidget {
  const PlanesMembresiaScreen({super.key});

  @override
  State<PlanesMembresiaScreen> createState() => _PlanesMembresiaScreenState();
}

class _PlanesMembresiaScreenState extends State<PlanesMembresiaScreen> {
  final PlanMembresiaService _planService = PlanMembresiaService();
  List<PlanMembresiaModel> _planes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPlanes();
  }

  Future<void> _cargarPlanes() async {
    setState(() => _isLoading = true);
    final lista = await _planService.getPlanes();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _planes = lista;
    });
  }

  void _showFormularioPlanDialog({PlanMembresiaModel? plan}) {
    final nombreCtrl = TextEditingController(text: plan?.nombre ?? '');
    final precioCtrl = TextEditingController(text: plan != null ? plan.precio.toStringAsFixed(0) : '');
    final duracionCtrl = TextEditingController(text: plan != null ? plan.duracionDias.toString() : '30');
    bool isSaving = false;

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
                  plan != null ? Icons.edit_note_rounded : Icons.card_membership_rounded,
                  color: const Color(0xFF00E676),
                ),
                const SizedBox(width: 10),
                Text(
                  plan != null ? 'Editar Plan' : 'Nuevo Plan de Membresía',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOMBRE DEL PLAN', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: Pase Libre Mensual',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('PRECIO (\$)', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: precioCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: 25000',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('DURACIÓN EN DÍAS', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: duracionCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: 30 para mensual, 90 trimestral',
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
                        final precio = double.tryParse(precioCtrl.text);
                        final duracion = int.tryParse(duracionCtrl.text);

                        if (nombre.isEmpty || precio == null || duracion == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor completa todos los campos con valores válidos.'),
                              backgroundColor: Color(0xFFC62828),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);

                        bool ok;
                        if (plan != null) {
                          ok = await _planService.updatePlan(
                            idPlan: plan.idPlanMembresia,
                            nombre: nombre,
                            precio: precio,
                            duracionDias: duracion,
                            estado: plan.estado,
                          );
                        } else {
                          ok = await _planService.createPlan(
                            nombre: nombre,
                            precio: precio,
                            duracionDias: duracion,
                          );
                        }

                        if (!context.mounted) return;
                        setDialogState(() => isSaving = false);
                        Navigator.pop(context);

                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(plan != null ? 'Plan actualizado.' : 'Plan creado exitosamente.'),
                              backgroundColor: const Color(0xFF1B5E20),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _cargarPlanes();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al guardar el plan de membresía.'),
                              backgroundColor: Color(0xFFB71C1C),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(plan != null ? 'Guardar' : 'Crear Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleEstadoPlan(PlanMembresiaModel plan) async {
    final ok = await _planService.desactivarPlan(plan.idPlanMembresia);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado de "${plan.nombre}" actualizado.'),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarPlanes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF12181B),
        elevation: 0,
        title: const Text(
          'Planes de Membresía',
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            tooltip: 'Actualizar',
            onPressed: _cargarPlanes,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showFormularioPlanDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : _planes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_membership_rounded, color: Color(0xFF7A8B94), size: 48),
                      const SizedBox(height: 12),
                      const Text('No hay planes de membresía creados.', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Crea tu primer plan (ej: Mensual, Pase Libre).', style: TextStyle(color: Color(0xFF7A8B94), fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF00E676),
                  backgroundColor: const Color(0xFF161E22),
                  onRefresh: _cargarPlanes,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _planes.length,
                    itemBuilder: (context, index) {
                      final p = _planes[index];
                      return _buildPlanCard(p);
                    },
                  ),
                ),
    );
  }

  Widget _buildPlanCard(PlanMembresiaModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isActivo
              ? const Color(0xFF00E676).withValues(alpha: 0.3)
              : const Color(0xFF243037),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_membership_rounded, color: Color(0xFF00E676), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    plan.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: plan.isActivo
                      ? const Color(0xFF00E676).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.estado.toUpperCase(),
                  style: TextStyle(
                    color: plan.isActivo ? const Color(0xFF00E676) : const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duración: ${plan.duracionTexto}',
                    style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${plan.precio.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                    tooltip: 'Editar',
                    onPressed: () => _showFormularioPlanDialog(plan: plan),
                  ),
                  IconButton(
                    icon: Icon(
                      plan.isActivo ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                      color: plan.isActivo ? const Color(0xFFF59E0B) : const Color(0xFF00E676),
                      size: 22,
                    ),
                    tooltip: plan.isActivo ? 'Desactivar plan' : 'Activar plan',
                    onPressed: () => _toggleEstadoPlan(plan),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
