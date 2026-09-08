import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color background = Color(0xFF131313);
  static const Color cardBackground = Color(0xFF222222);
  static const Color primaryGreen = Color(0xFF7DE610); // Verde lima vibrante
  static const Color darkGreenButton = Color(0xFF072709); // Verde muy oscuro para botón registrarse
  static const Color darkGreenBorder = Color(0xFF114216);
  static const Color memberCyan = Color(0xFF38BDF8); // "¿Eres socio?"
  static const Color forgotGreen = Color(0xFF86EFAC); // "¿Olvidaste tu contraseña?"
  static const Color textWhite = Colors.white;
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color borderGreen = Color(0xFF7DE610);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        surface: cardBackground,
        onPrimary: Colors.black,
        onSurface: textWhite,
      ),
      fontFamily: 'Roboto',
    );
  }
}
