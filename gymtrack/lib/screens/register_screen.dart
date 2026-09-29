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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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

    final email = _emailController.text.trim();
    final nameFromEmail = email.contains('@') ? email.split('@')[0] : 'Usuario';
    final formattedName = nameFromEmail.isNotEmpty
        ? '${nameFromEmail[0].toUpperCase()}${nameFromEmail.substring(1)}'
        : 'Usuario';

    final authService = AuthService();
    final response = await authService.register(
      nombre: formattedName,
      apellido: '',
      email: email,
      password: _passwordController.text,
      nombreGimnasio: null,
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

      // Navegar según tenga o no gimnasio configurado
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
        "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de GymTrack
                  const GymLogo(size: 130),
                  const SizedBox(height: 24),

                  // Tarjeta oscura del formulario
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
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
                          // 1. Campo de Correo Electrónico
                          CustomTextField(
                            controller: _emailController,
                            label: 'CORREO ELECTRONICO',
                            hintText: 'tucorreo@gmail.com',
                            prefixIcon: Icons.person_outline,
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
                          const SizedBox(height: 18),

                          // 2. Campo de Contraseña
                          CustomTextField(
                            controller: _passwordController,
                            label: 'CONTRASEÑA',
                            hintText: '**********',
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
                          const SizedBox(height: 18),

                          // 3. Campo de Repetir Contraseña
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'REPETIR CONTRASEÑA',
                            hintText: '**********',
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

                          // Botón REGISTRARSE (Verde oscuro con borde y texto blanco en mayúsculas)
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Enlace discreto para volver al inicio de sesión
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


