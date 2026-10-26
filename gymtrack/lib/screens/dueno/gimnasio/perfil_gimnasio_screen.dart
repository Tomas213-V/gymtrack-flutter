import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/gimnasio_service.dart';
import '../../../theme/app_theme.dart';

class PerfilGimnasioScreen extends StatefulWidget {
  final UserModel? user;

  const PerfilGimnasioScreen({super.key, this.user});

  @override
  State<PerfilGimnasioScreen> createState() => _PerfilGimnasioScreenState();
}

class _PerfilGimnasioScreenState extends State<PerfilGimnasioScreen> {
  final GimnasioService _gimnasioService = GimnasioService();
  GymModel? _gym;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gym = widget.user?.gimnasio ?? AuthService().currentUser?.gimnasio;
    _cargarGimnasio();
  }

  Future<void> _cargarGimnasio() async {
    setState(() => _isLoading = true);
    final gym = await _gimnasioService.getMiGimnasio();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (gym != null) {
        _gym = gym;
      }
    });
  }

  void _showEditarDialog() {
    if (_gym == null) return;

    final nombreCtrl = TextEditingController(text: _gym!.nombre);
    final direccionCtrl = TextEditingController(text: _gym!.direccion ?? '');
    final telefonoCtrl = TextEditingController(text: _gym!.telefono ?? '');
    final emailCtrl = TextEditingController(text: _gym!.email ?? '');
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
                      Icon(Icons.edit_location_alt_rounded, color: Color(0xFF00E676), size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Editar Datos de la Sede',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  const Text('NOMBRE DEL GIMNASIO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.storefront_outlined, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('DIRECCIÓN', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: direccionCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('TELÉFONO DE CONTACTO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: telefonoCtrl,
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

                  const Text('CORREO ELECTRÓNICO INSTITUCIONAL', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                              final nombre = nombreCtrl.text.trim();
                              if (nombre.isEmpty) return;

                              setModalState(() => isSaving = true);

                              final ok = await _gimnasioService.actualizarGimnasio(
                                nombre: nombre,
                                direccion: direccionCtrl.text,
                                telefono: telefonoCtrl.text,
                                email: emailCtrl.text,
                              );

                              if (!context.mounted) return;

                              setModalState(() => isSaving = false);
                              Navigator.pop(context);

                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Datos del gimnasio actualizados.'),
                                    backgroundColor: Color(0xFF1B5E20),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                _cargarGimnasio();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No se pudieron actualizar los datos.'),
                                    backgroundColor: Color(0xFFB71C1C),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6)),
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

  void _showEditarPerfilDuenoDialog() {
    final currentUser = AuthService().currentUser ?? widget.user;
    final nombreCtrl = TextEditingController(text: currentUser?.nombre ?? '');
    final apellidoCtrl = TextEditingController(text: currentUser?.apellido ?? '');
    final emailCtrl = TextEditingController(text: currentUser?.email ?? '');
    final actualPassCtrl = TextEditingController();
    final nuevaPassCtrl = TextEditingController();
    bool isSaving = false;
    bool obscureCurrent = true;
    bool obscureNew = true;

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
                      Icon(Icons.manage_accounts_rounded, color: Color(0xFF00E676), size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Perfil del Administrador',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  const Text('NOMBRE', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('APELLIDO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: apellidoCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('CORREO ELECTRÓNICO', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00E676), size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('CAMBIAR CONTRASEÑA (OPCIONAL)', style: TextStyle(color: Color(0xFFFFB300), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: actualPassCtrl,
                    obscureText: obscureCurrent,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña actual',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFB300), size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 18),
                        onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nuevaPassCtrl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña (mínimo 6 caracteres)',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F292E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFFFFB300), size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 18),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                              final nombre = nombreCtrl.text.trim();
                              final apellido = apellidoCtrl.text.trim();
                              final email = emailCtrl.text.trim();

                              if (nombre.isEmpty || apellido.isEmpty || email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Por favor completa nombre, apellido y email.')),
                                );
                                return;
                              }

                              if (nuevaPassCtrl.text.isNotEmpty && actualPassCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Debes ingresar tu contraseña actual para cambiarla.')),
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);

                              final res = await AuthService().updateOwnerProfile(
                                nombre: nombre,
                                apellido: apellido,
                                email: email,
                                contrasenaActual: actualPassCtrl.text.isNotEmpty ? actualPassCtrl.text : null,
                                nuevaContrasena: nuevaPassCtrl.text.isNotEmpty ? nuevaPassCtrl.text : null,
                              );

                              if (!context.mounted) return;
                              setModalState(() => isSaving = false);
                              Navigator.pop(context);

                              if (res.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.message),
                                    backgroundColor: const Color(0xFF1B5E20),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.message),
                                    backgroundColor: const Color(0xFFB71C1C),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('GUARDAR PERFIL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6)),
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
    final gym = _gym;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF12181B),
        elevation: 0,
        title: const Text(
          'Perfil del Gimnasio',
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            tooltip: 'Actualizar',
            onPressed: _cargarGimnasio,
          ),
        ],
      ),
      body: _isLoading && gym == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : RefreshIndicator(
              color: const Color(0xFF00E676),
              backgroundColor: const Color(0xFF161E22),
              onRefresh: _cargarGimnasio,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  // Tarjeta principal del gimnasio
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E22),
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
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00E676), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.fitness_center_rounded, color: Color(0xFF00E676), size: 36),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          gym?.nombre ?? 'Mi Gimnasio',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E676),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Sede Principal Activa',
                              style: TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                            label: const Text('Editar Información', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _showEditarDialog,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Detalles del Gimnasio
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E22),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF243037)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de la Sede',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        _buildRow(Icons.location_on_outlined, 'Dirección', gym?.direccion ?? 'No especificada'),
                        const Divider(color: Color(0xFF243037), height: 22),
                        _buildRow(Icons.phone_outlined, 'Teléfono', gym?.telefono ?? 'No registrado'),
                        const Divider(color: Color(0xFF243037), height: 22),
                        _buildRow(Icons.email_outlined, 'Correo electrónico', gym?.email ?? 'No registrado'),
                        const Divider(color: Color(0xFF243037), height: 22),
                        _buildRow(Icons.access_time_rounded, 'Horarios de atención', 'Lunes a Viernes: 07:00 a 22:00 hs\nSábados: 09:00 a 18:00 hs'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Perfil del Administrador / Dueño
                  Builder(
                    builder: (context) {
                      final u = AuthService().currentUser ?? widget.user;
                      return Container(
                        padding: const EdgeInsets.all(20),
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
                                const Text(
                                  'Mi Cuenta y Seguridad',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF00E676), size: 20),
                                  tooltip: 'Editar Perfil',
                                  onPressed: _showEditarPerfilDuenoDialog,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildRow(Icons.person_outline, 'Nombre completo', '${u?.nombre ?? ""} ${u?.apellido ?? ""}'.trim().isNotEmpty ? '${u?.nombre ?? ""} ${u?.apellido ?? ""}'.trim() : 'Administrador'),
                            const Divider(color: Color(0xFF243037), height: 22),
                            _buildRow(Icons.email_outlined, 'Correo personal', u?.email ?? 'No disponible'),
                            const Divider(color: Color(0xFF243037), height: 22),
                            _buildRow(Icons.security_rounded, 'Rol de acceso', 'Dueño / Administrador Central'),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.lock_reset_rounded, size: 18, color: Color(0xFF00E676)),
                                label: const Text('Modificar Datos y Contraseña', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF00E676)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                ),
                                onPressed: _showEditarPerfilDuenoDialog,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E676), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A98A0), fontSize: 12)),
              const SizedBox(height: 3),
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
