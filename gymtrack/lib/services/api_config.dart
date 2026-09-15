import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Permite sobrescribir la IP o host manualmente si se prueba en un dispositivo físico.
  static String? customBaseUrl;

  /// Retorna la URL base adecuada según la plataforma donde corre la app.
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    try {
      if (Platform.isAndroid) {
        // En emuladores Android 10.0.2.2 apunta al localhost de la máquina anfitriona
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {
      // En plataformas donde Platform no esté disponible o falle
    }

    // Windows Desktop, macOS, Linux, iOS Simulator
    return 'http://localhost:3000';
  }

  // Endpoints de autenticación
  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/register';
  static String get meUrl => '$baseUrl/api/auth/me';
  static String get healthUrl => '$baseUrl/api/health';

  // Endpoints de gimnasios
  static String get gimnasiosUrl => '$baseUrl/api/gimnasios';
  static String get miGimnasioUrl => '$baseUrl/api/gimnasios/mi-gimnasio';

  // Endpoints de socios
  static String get sociosUrl => '$baseUrl/api/socios';
  static String get sociosStatsUrl => '$baseUrl/api/socios/estadisticas';

  // Endpoints de pagos
  static String get pagosUrl => '$baseUrl/api/pagos';
  static String get pagosResumenUrl => '$baseUrl/api/pagos/resumen';
  static String get pagosMembresiasUrl => '$baseUrl/api/pagos/membresias';
}
