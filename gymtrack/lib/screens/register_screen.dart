import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_button.dart';
import '../widgets/gym_logo.dart';
import 'gym_setup_screen.dart';
import 'main_layout_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _gymNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _gymNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final response = await authService.register(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombreGimnasio: _gymNameController.text.trim().isNotEmpty
          ? _gymNameController.text.trim()
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

      final user = response.user!;
      final hasGym = user.gimnasio != null;

      // Navegar según tenga o no gimnasio
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => hasGym
              ? MainLayoutScreen(user: user)
              : GymSetupScreen(user: user),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  response.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de GymTrack
                  const GymLogo(size: 110),
                  const SizedBox(height: 20),

                  // Tarjeta oscura del formulario
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
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
                          // 1. Campo de Nombre
                          CustomTextField(
                            controller: _nombreController,
                            label: 'NOMBRE',
                            hintText: 'Tu nombre',
                            prefixIcon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Campo de Apellido
                          CustomTextField(
                            controller: _apellidoController,
                            label: 'APELLIDO',
                            hintText: 'Tu apellido',
                            prefixIcon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingresa tu apellido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 3. Campo de Correo Electrónico
                          CustomTextField(
                            controller: _emailController,
                            label: 'CORREO ELECTRONICO',
                            hintText: 'tucorreo@gmail.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingresa tu correo electrónico';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Campo de Nombre de Gimnasio (Opcional)
                          CustomTextField(
                            controller: _gymNameController,
                            label: 'NOMBRE DEL GIMNASIO (OPCIONAL)',
                            hintText: 'Ej. PowerGym Fitness',
                            prefixIcon: Icons.fitness_center_outlined,
                          ),
                          const SizedBox(height: 16),

                          // 5. Campo de Contraseña
                          CustomTextField(
                            controller: _passwordController,
                            label: 'CONTRASEÑA',
                            hintText: 'Mínimo 6 caracteres',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 6. Campo de Repetir Contraseña
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'REPETIR CONTRASEÑA',
                            hintText: 'Confirma tu contraseña',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, repite la contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botón REGISTRARSE (Verde oscuro)
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.darkGreenButton,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppTheme.darkGreenButton.withValues(alpha: 0.6),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppTheme.darkGreenBorder,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  )
                                : const Text(
                                    'REGISTRARSE',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Continuar con Google
                          GoogleSignInSection(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Iniciar sesión con Google...'),
                                  backgroundColor: AppTheme.cardBackground,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          // Enlace para volver a iniciar sesión
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              '¿Ya tienes cuenta? Iniciar sesión',
                              style: TextStyle(
                                color: AppTheme.memberCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

