import 'package:flutter/material.dart';
import '../../mock/socio_mock_data.dart';
import '../../models/socio_mock_models.dart';
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
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
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
        ),
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
