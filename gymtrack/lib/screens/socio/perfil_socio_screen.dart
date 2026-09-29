import 'package:flutter/material.dart';
import '../../models/perfil_socio_model.dart';
import '../../services/auth_service.dart';
import '../../services/socio_service.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class PerfilSocioScreen extends StatefulWidget {
  final int? idSocio;

  const PerfilSocioScreen({super.key, this.idSocio});

  @override
  State<PerfilSocioScreen> createState() => _PerfilSocioScreenState();
}

class _PerfilSocioScreenState extends State<PerfilSocioScreen> {
  final SocioService _socioService = SocioService();
  PerfilSocioModel? _perfil;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final perfil = await _socioService.getPerfilSocio(idSocio: widget.idSocio);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (perfil != null) {
        _perfil = perfil;
      } else {
        _errorMessage = 'No se pudo cargar la información del perfil.';
      }
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161D21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que deseas salir de tu cuenta?',
          style: TextStyle(color: Color(0xFFB0BEC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8A98A0))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              AuthService().logout();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditarPerfilDialog() {
    if (_perfil == null) return;

    final telController = TextEditingController(text: _perfil!.telefono ?? '');
    final emailController = TextEditingController(text: _perfil!.email ?? '');
    final passActualController = TextEditingController();
    final passNuevaController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161D21),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: Color(0xFF00E676), size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Actualizar Mis Datos',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Teléfono
                  const Text('TELÉFONO DE CONTACTO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: telController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Email
                  const Text('CORREO ELECTRÓNICO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Divider(color: Color(0xFF2A3840)),
                  const SizedBox(height: 10),
                  const Text(
                    'Cambiar contraseña (opcional)',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: passActualController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña actual',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7A8B94), size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: passNuevaController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña (mínimo 6 caracteres)',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              final res = await _socioService.updatePerfilSocio(
                                idSocio: _perfil!.idSocio,
                                telefono: telController.text,
                                email: emailController.text,
                                contrasenaActual: passActualController.text.isNotEmpty
                                    ? passActualController.text
                                    : null,
                                nuevaContrasena: passNuevaController.text.isNotEmpty
                                    ? passNuevaController.text
                                    : null,
                              );

                              if (!context.mounted) return;

                              setModalState(() => isSaving = false);
                              Navigator.pop(context);

                              if (res['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Perfil actualizado exitosamente.'),
                                    backgroundColor: Color(0xFF1B5E20),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                _cargarPerfil();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['error'] ?? 'Error al actualizar perfil.'),
                                    backgroundColor: const Color(0xFFB71C1C),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                            )
                          : const Text(
                              'GUARDAR CAMBIOS',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
        ),
        title: const Text(
          'Perfil del Socio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            tooltip: 'Actualizar',
            onPressed: _cargarPerfil,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Cerrar sesión',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E676)),
      );
    }

    if (_errorMessage != null || _perfil == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 14),
              Text(
                _errorMessage ?? 'No se pudo cargar la información.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _cargarPerfil,
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text('Reintentar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final p = _perfil!;

    return RefreshIndicator(
      color: const Color(0xFF00E676),
      backgroundColor: const Color(0xFF161D21),
      onRefresh: _cargarPerfil,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          // 1. Tarjeta de Encabezado de Socio
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161D21),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF243037)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar con iniciales
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        border: Border.all(color: const Color(0xFF00E676), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          p.iniciales,
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nombreCompleto,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Socio #${p.idSocio} • DNI ${p.dni}',
                            style: const TextStyle(
                              color: Color(0xFF8A98A0),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: p.isActivo
                                      ? const Color(0xFF00E676).withValues(alpha: 0.15)
                                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p.isActivo ? 'ACTIVO' : 'INACTIVO',
                                  style: TextStyle(
                                    color: p.isActivo ? const Color(0xFF00E676) : const Color(0xFFEF4444),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.gimnasioNombre ?? 'Gimnasio',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF243037)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Asistencias', '${p.totalAsistencias}', Icons.check_circle_outline_rounded),
                    Container(width: 1, height: 30, color: const Color(0xFF243037)),
                    _buildStatItem('Pagos', '${p.totalPagos}', Icons.receipt_long_rounded),
                    Container(width: 1, height: 30, color: const Color(0xFF243037)),
                    _buildStatItem(
                      'Días Restantes',
                      p.diasRestantes != null ? '${p.diasRestantes}d' : '-',
                      Icons.hourglass_top_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Tarjeta de Estado de Membresía
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161D21),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: p.isActivo
                    ? const Color(0xFF00E676).withValues(alpha: 0.3)
                    : const Color(0xFFEF4444).withValues(alpha: 0.3),
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
                        const Icon(Icons.card_membership_rounded, color: Color(0xFF00E676), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          p.planNombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (p.precioMembresia != null)
                      Text(
                        '\$${p.precioMembresia!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (p.fechaVencimiento != null)
                  Text(
                    'Vencimiento: ${p.fechaVencimiento}',
                    style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                  )
                else
                  const Text(
                    'Sin fecha de vencimiento registrada',
                    style: TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Información Personal
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161D21),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF243037)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Información de Contacto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF00E676), size: 20),
                      tooltip: 'Editar',
                      onPressed: _showEditarPerfilDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.email_outlined, 'Correo electrónico', p.email ?? 'No registrado'),
                const Divider(color: Color(0xFF243037), height: 20),
                _buildInfoRow(Icons.phone_outlined, 'Teléfono', p.telefono ?? 'No registrado'),
                const Divider(color: Color(0xFF243037), height: 20),
                _buildInfoRow(Icons.badge_outlined, 'DNI', p.dni),
                if (p.fechaAlta != null) ...[
                  const Divider(color: Color(0xFF243037), height: 20),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Fecha de ingreso', p.fechaAlta!),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Últimas Asistencias
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161D21),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF243037)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF00E676), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Últimas Asistencias',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (p.ultimasAsistencias.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No hay asistencias registradas recientemente.',
                      style: TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                    ),
                  )
                else
                  ...p.ultimasAsistencias.map(
                    (a) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                a.fechaFormateada,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Text(
                            a.horaIngresoFormateada,
                            style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Historial de Pagos
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161D21),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF243037)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.payment_rounded, color: Color(0xFF00E676), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Historial de Pagos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (p.ultimosPagos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No hay pagos registrados para este socio.',
                      style: TextStyle(color: Color(0xFF8A98A0), fontSize: 13),
                    ),
                  )
                else
                  ...p.ultimosPagos.map(
                    (pago) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pago.fechaFormateada,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                pago.metodoPago,
                                style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            '\$${pago.monto.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón Cerrar Sesión
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _handleLogout,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00E676), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A98A0),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E676), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
