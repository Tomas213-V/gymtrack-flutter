import 'package:flutter/material.dart';
import '../../models/socio_mock_models.dart';
import '../../repositories/progreso_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/socio/socio_weight_chart.dart';
import 'registrar_progreso_screen.dart';

class MiProgresoScreen extends StatefulWidget {
  final bool showBackButton;

  const MiProgresoScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<MiProgresoScreen> createState() => _MiProgresoScreenState();
}

class _MiProgresoScreenState extends State<MiProgresoScreen> {
  final IProgresoRepository _progresoRepository = ProgresoRepository.instance;
  SocioProfileModel? _profile;
  List<ProgresoRegistroModel> _registros = [];
  List<ProgresoPuntoModel> _puntosGrafico = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    setState(() => _isLoading = true);
    final prof = await _progresoRepository.getPerfilProgreso();
    final regs = await _progresoRepository.getRegistrosProgreso();
    final pts = await _progresoRepository.getPuntosGrafico();

    if (!mounted) return;
    setState(() {
      _profile = prof;
      _registros = regs;
      _puntosGrafico = pts;
      _isLoading = false;
    });
  }

  Future<void> _navegarARegistrar() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegistrarProgresoScreen(),
      ),
    );

    if (result == true || mounted) {
      await _cargarProgreso();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final registros = _registros;

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
          'Mi Progreso',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarARegistrar,
        backgroundColor: const Color(0xFF7DE610),
        foregroundColor: Colors.black,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.black),
      ),
      body: SafeArea(
        child: _isLoading && profile == null
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF7DE610)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila de Tarjetas de Estadísticas Principales
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'PESO ACTUAL',
                            value: '${profile!.pesoActual.toStringAsFixed(1)} kg',
                            valueColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            label: 'PESO INICIAL',
                            value: '${profile.pesoInicial.toStringAsFixed(0)} kg',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            label: 'CAMBIO TOTAL',
                            value: '${profile.cambioTotal > 0 ? "+" : ""}${profile.cambioTotal.toStringAsFixed(0)} kg',
                            valueColor: const Color(0xFF7DE610),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'ENTRENAMIENTOS',
                            value: '${profile.totalEntrenamientos}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox()),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sección Evolución de peso
                    const Text(
                      'Evolución de peso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SocioWeightChart(puntos: _puntosGrafico),

                    const SizedBox(height: 26),

                    // Sección Historial de registros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Historial de registros',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _navegarARegistrar,
                          child: const Text(
                            '+ Registrar',
                            style: TextStyle(
                              color: Color(0xFF7DE610),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lista de registros
                    ...registros.map((reg) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF2C2C2E)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.monitor_weight_outlined,
                                    color: Color(0xFF7DE610),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reg.fecha,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reg.nota,
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${reg.peso.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  color: Color(0xFF7DE610),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
