import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gym_logo.dart';
import 'socio_main_layout_screen.dart';

class LoginSocioScreen extends StatefulWidget {
  const LoginSocioScreen({super.key});

  @override
  State<LoginSocioScreen> createState() => _LoginSocioScreenState();
}

class _LoginSocioScreenState extends State<LoginSocioScreen> {
  final _socioNumberController = TextEditingController(text: '112256407');
  final _passwordController = TextEditingController(text: '••••••••••••');
  final _dniController = TextEditingController(text: '41234567');

  bool _obscurePassword = true;
  bool _obscureDni = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _socioNumberController.dispose();
    _passwordController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _isLoading = true;
    });

    // Simulación de login con datos MOCK
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SocioMainLayoutScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo circular
                  const GymLogo(size: 130),
                  const SizedBox(height: 30),

                  // Tarjeta oscura del formulario
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Campo Número de socio
                        _buildOutlinedInput(
                          label: 'Número de socio',
                          controller: _socioNumberController,
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 20),

                        // 2. Campo Contraseña
                        _buildOutlinedInput(
                          label: 'Contraseña',
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF7DE610),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. Campo DNI
                        _buildOutlinedInput(
                          label: 'DNI',
                          controller: _dniController,
                          icon: Icons.lock_outline,
                          obscureText: _obscureDni,
                          keyboardType: TextInputType.number,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureDni ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF7DE610),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureDni = !_obscureDni;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Botón Ingresar
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF072709),
                              foregroundColor: const Color(0xFF7DE610),
                              side: const BorderSide(
                                color: Color(0xFF114216),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF7DE610),
                                    ),
                                  )
                                : const Text(
                                    'Ingresar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF7DE610),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Volver al acceso de administrador
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: AppTheme.textMuted,
                    ),
                    label: const Text(
                      'Volver al acceso de administrador',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildOutlinedInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7DE610),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF7DE610),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF7DE610),
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
