import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gym_logo.dart';
import 'login_screen.dart';
import 'main_layout_screen.dart';

class GymSetupScreen extends StatefulWidget {
  final UserModel user;

  const GymSetupScreen({
    super.key,
    required this.user,
  });

  @override
  State<GymSetupScreen> createState() => _GymSetupScreenState();
}

class _GymSetupScreenState extends State<GymSetupScreen> {
  final _gymNameController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _gymNameController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveGym() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final response = await authService.registrarGimnasio(
      nombre: _gymNameController.text.trim(),
      direccion: _direccionController.text.trim().isNotEmpty
          ? _direccionController.text.trim()
          : null,
      telefono: _telefonoController.text.trim().isNotEmpty
          ? _telefonoController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.success && response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Ir directo al Dashboard principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainLayoutScreen(user: response.user!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleLogout() {
    AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GymLogo(size: 100),
                  const SizedBox(height: 20),

                  // Título principal
                  const Text(
                    '¡Bienvenido a GymTrack!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hola ${widget.user.nombre}, antes de continuar necesitamos los datos de tu gimnasio para configurar tu panel.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F9CA3),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tarjeta con formulario
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF182024),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF27343B), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Nombre del Gimnasio
                          CustomTextField(
                            controller: _gymNameController,
                            label: 'NOMBRE DEL GIMNASIO *',
                            hintText: 'Ej: Iron Gym, Fit Center...',
                            prefixIcon: Icons.fitness_center_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingresa el nombre de tu gimnasio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Dirección
                          CustomTextField(
                            controller: _direccionController,
                            label: 'DIRECCIÓN',
                            hintText: 'Av. Siempre Viva 742',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),

                          // 3. Teléfono
                          CustomTextField(
                            controller: _telefonoController,
                            label: 'TELÉFONO DE CONTACTO',
                            hintText: '11 2345 6789',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // 4. Email del Gimnasio
                          CustomTextField(
                            controller: _emailController,
                            label: 'EMAIL PÚBLICO (OPCIONAL)',
                            hintText: 'contacto@irongym.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 28),

                          // Botón Guardar y Continuar
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSaveGym,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'REGISTRAR Y ENTRAR AL DASHBOARD',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF8F9CA3)),
                    label: const Text(
                      'Cerrar sesión e ingresar con otra cuenta',
                      style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
