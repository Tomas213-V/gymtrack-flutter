import 'package:flutter/material.dart';
import '../models/asistencia_model.dart';
import '../services/asistencia_service.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  final AsistenciaService _asistenciaService = AsistenciaService();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<AsistenciaItemModel> _ingresos = [];
  bool _isLoading = true;
  bool _isRegistering = false;
  int _totalIngresos = 0;

  int _presentesHoy = 0;
  int _ingresosHoy = 0;
  int _promedioDiario = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    final fechaStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final res = await _asistenciaService.getAsistencias(
      desde: fechaStr,
      hasta: fechaStr,
      search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
    );

    final stats = await _asistenciaService.getEstadisticas();

    if (!mounted) return;

    final lista = (res['asistencias'] as List<AsistenciaItemModel>?) ?? [];
    final total = res['total'] as int? ?? lista.length;

    setState(() {
      _isLoading = false;
      _ingresos = lista;
      _totalIngresos = total;
      _ingresosHoy = stats.ingresosHoy > 0 ? stats.ingresosHoy : lista.length;
      _presentesHoy = lista.where((a) => a.estado.toLowerCase() == 'presente').length;
      _promedioDiario = stats.totalMesActual > 0 ? (stats.totalMesActual ~/ 30) : lista.length;
    });
  }

  Future<void> _marcarEntrada() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresá el DNI o ID del socio.'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);

    final res = await _asistenciaService.registrarAsistencia(dni: codigo);

    if (!mounted) return;

    setState(() => _isRegistering = false);

    if (res['success'] == true) {
      _codigoController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  res['mensaje'] ?? '¡Entrada registrada con éxito!',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      _cargarDatos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['mensaje'] ?? 'Error al registrar asistencia.'),
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _marcarSalida(AsistenciaItemModel item) async {
    final ok = await _asistenciaService.checkoutAsistencia(item.idAsistencia);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Salida registrada para ${item.socioNombreCompleto}'),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarDatos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo registrar la salida.'),
          backgroundColor: Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Colors.black,
              surface: Color(0xFF161E22),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF161E22),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _cargarDatos();
    }
  }

  String _formatDate(DateTime d) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final now = DateTime.now();
    final esHoy = d.year == now.year && d.month == now.month && d.day == now.day;
    if (esHoy) {
      return 'Hoy, ${d.day} ${meses[d.month - 1]}';
    }
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00E676),
          backgroundColor: const Color(0xFF161E22),
          onRefresh: _cargarDatos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Encabezado con Icono, Título y Selector de Fecha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF00E676),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asistencia',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Registra la entrada de los socios',
                            style: TextStyle(
                              color: Color(0xFF8F9CA3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón Selector de Fecha
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF27343B), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF8F9CA3)),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF8F9CA3)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Tarjeta de Registrar Asistencia
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF243037), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'Registrar asistencia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Ingresá el DNI del socio para registrar su ingreso',
                          style: TextStyle(
                            color: Color(0xFF8F9CA3),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'DNI o Código de Socio',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Campo de texto de código
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1416),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF27343B), width: 1),
                        ),
                        child: TextField(
                          controller: _codigoController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Ej: 41234567',
                            hintStyle: TextStyle(color: Color(0xFF5A6B74), fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF00E676), size: 18),
                          ),
                          onSubmitted: (_) => _marcarEntrada(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Botón Marcar Entrada
                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _isRegistering ? null : _marcarEntrada,
                          icon: _isRegistering
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.login_rounded, size: 18, color: Colors.black),
                          label: Text(
                            _isRegistering ? 'Registrando...' : 'Marcar entrada',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Tarjetas de Métricas
                SizedBox(
                  height: 104,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildMetricCard(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF00E676),
                        label: 'Presentes hoy',
                        value: _presentesHoy.toString(),
                        subtext: 'En sala ahora',
                        subtextColor: const Color(0xFF00E676),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        icon: Icons.login_rounded,
                        iconColor: const Color(0xFF38BDF8),
                        label: 'Ingresos hoy',
                        value: _ingresosHoy.toString(),
                        subtext: 'Fecha actual',
                        subtextColor: const Color(0xFF38BDF8),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Promedio diario',
                        value: _promedioDiario.toString(),
                        subtext: 'Mensual estimado',
                        subtextColor: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        icon: Icons.assignment_turned_in_rounded,
                        iconColor: const Color(0xFFA78BFA),
                        label: 'Total fecha',
                        value: _totalIngresos.toString(),
                        subtext: 'Registros',
                        subtextColor: const Color(0xFFA78BFA),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Encabezado de Ingresos Recientes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registros (${_ingresos.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676), size: 20),
                      tooltip: 'Actualizar',
                      onPressed: _cargarDatos,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 5. Lista de Ingresos Recientes
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
                  )
                else if (_ingresos.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF243037)),
                    ),
                    child: const Center(
                      child: Text(
                        'No hay asistencias registradas para esta fecha.',
                        style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._ingresos.map((item) => _buildIngresoCard(item)),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtext,
    required Color subtextColor,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243037), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8F9CA3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              color: subtextColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngresoCard(AsistenciaItemModel item) {
    final isPresente = item.estado.toLowerCase() == 'presente';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161E22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243037), width: 1),
      ),
      child: Row(
        children: [
          // Avatar Iniciales
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.15),
            child: Text(
              item.socioNombre.isNotEmpty ? item.socioNombre[0].toUpperCase() : 'S',
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Datos del socio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.socioNombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'DNI: ${item.socioDni} • ${item.horaFormateada} hs',
                  style: const TextStyle(
                    color: Color(0xFF8F9CA3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Estado o botón de Checkout
          if (isPresente)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F292E),
                foregroundColor: const Color(0xFF00E676),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF00E676), width: 1),
                ),
                elevation: 0,
              ),
              onPressed: () => _marcarSalida(item),
              child: const Text('Salida', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF243037),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Completado',
                style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
