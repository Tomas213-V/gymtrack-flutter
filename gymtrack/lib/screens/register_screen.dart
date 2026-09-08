import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_button.dart';
import '../widgets/gym_logo.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    // Aquí se conectará con el backend en Node.js
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Procesando registro...'),
        backgroundColor: AppTheme.cardBackground,
      ),
    );
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
                  const GymLogo(size: 130),
                  const SizedBox(height: 28),

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
                          ),
                          const SizedBox(height: 18),

                          // 2. Campo de Contraseña
                          CustomTextField(
                            controller: _passwordController,
                            label: 'CONTRASEÑA',
                            hintText: '**********',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 18),

                          // 3. Campo de Repetir Contraseña
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'REPETIR CONTRASEÑA',
                            hintText: '**********',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 26),

                          // Botón REGISTRARSE (Verde oscuro)
                          ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.darkGreenButton,
                              foregroundColor: Colors.white,
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
                            child: const Text(
                              'REGISTRARSE',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

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
