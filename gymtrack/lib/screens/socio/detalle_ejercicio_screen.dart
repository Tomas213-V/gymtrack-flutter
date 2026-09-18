import 'package:flutter/material.dart';
import '../../mock/socio_mock_data.dart';
import '../../models/socio_mock_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/socio/socio_badge.dart';

class DetalleEjercicioScreen extends StatefulWidget {
  final EjercicioModel ejercicio;
  final VoidCallback? onStatusChanged;

  const DetalleEjercicioScreen({
    super.key,
    required this.ejercicio,
    this.onStatusChanged,
  });

  @override
  State<DetalleEjercicioScreen> createState() => _DetalleEjercicioScreenState();
}

class _DetalleEjercicioScreenState extends State<DetalleEjercicioScreen> {
  late bool _completado;

  @override
  void initState() {
    super.initState();
    _completado = widget.ejercicio.completado;
  }

  void _toggleCompletado() {
    setState(() {
      _completado = !_completado;
      widget.ejercicio.completado = _completado;
    });

    SocioMockData().toggleEjercicioCompletado(widget.ejercicio.id);
    widget.onStatusChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _completado ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _completado
                    ? '¡${widget.ejercicio.nombre} marcado como completado!'
                    : 'Estado actualizado',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _completado ? const Color(0xFF1B5E20) : const Color(0xFF2E2E2E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalle del ejercicio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contenedor visual del ejercicio
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF262626),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7DE610).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF7DE610).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Color(0xFF7DE610),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tags
                    Row(
                      children: [
                        SocioBadge.pill(text: widget.ejercicio.grupoMuscular),
                        const SizedBox(width: 8),
                        SocioBadge.pill(text: widget.ejercicio.categoria),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Título del ejercicio
                    Text(
                      widget.ejercicio.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección Instrucciones
                    const Text(
                      'INSTRUCCIONES',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.ejercicio.instrucciones,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4 Cajas de métricas (Series, Repeticiones, Peso, Descanso)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricBox(
                            label: 'SERIES',
                            value: widget.ejercicio.series.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricBox(
                            label: 'REPETICIONES',
                            value: widget.ejercicio.repeticiones.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricBox(
                            label: 'PESO',
                            value: widget.ejercicio.peso,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildMetricBox(
                            label: 'DESCANSO',
                            value: widget.ejercicio.descanso,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(flex: 2, child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Botón inferior Marcar como realizado
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _toggleCompletado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _completado ? const Color(0xFF1B5E20) : const Color(0xFF7DE610),
                    foregroundColor: _completado ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: _completado ? Colors.white : Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _completado ? 'Ejercicio realizado' : 'Marcar como realizado',
                        style: TextStyle(
                          color: _completado ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF282828),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF7DE610),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
