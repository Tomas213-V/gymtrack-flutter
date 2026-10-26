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
  static String get loginSocioUrl => '$baseUrl/api/auth/login-socio';
  static String get registerUrl => '$baseUrl/api/auth/register';
  static String get meUrl => '$baseUrl/api/auth/me';
  static String get perfilDuenoUrl => '$baseUrl/api/auth/perfil';
  static String get healthUrl => '$baseUrl/api/health';

  // Endpoints de gimnasios
  static String get gimnasiosUrl => '$baseUrl/api/gimnasios';
  static String get miGimnasioUrl => '$baseUrl/api/gimnasios/mi-gimnasio';

  // Endpoints de socios y perfil
  static String get sociosUrl => '$baseUrl/api/socios';
  static String get sociosStatsUrl => '$baseUrl/api/socios/estadisticas';
  static String get perfilSocioUrl => '$baseUrl/api/socios/perfil';
  static String get verificarDniUrl => '$baseUrl/api/socios/verificar-dni';

  // Endpoints de pagos y dashboard dueño
  static String get pagosUrl => '$baseUrl/api/pagos';
  static String get pagosResumenUrl => '$baseUrl/api/pagos/resumen';
  static String get pagosMembresiasUrl => '$baseUrl/api/pagos/membresias';
  static String get dashboardAdminUrl => '$baseUrl/api/dashboard/admin';

  // Endpoints de asistencias
  static String get asistenciasUrl => '$baseUrl/api/asistencias';
  static String get asistenciasEstadisticasUrl => '$baseUrl/api/asistencias/estadisticas';

  // Endpoints de rutinas y ejercicios
  static String get rutinasUrl => '$baseUrl/api/rutinas';
  static String get rutinasOfrecidasGymUrl => '$baseUrl/api/rutinas/gym/ofrecidas';
  static String get rutinasAdoptarUrl => '$baseUrl/api/rutinas/adoptar';
  static String get ejerciciosUrl => '$baseUrl/api/ejercicios';
  static String get ejerciciosDisponiblesUrl => '$baseUrl/api/ejercicios/disponibles';
  static String get socioEjerciciosUrl => '$baseUrl/api/socio/ejercicios';

  // Endpoints de planes de membresía
  static String get planesMembresiaUrl => '$baseUrl/api/planes-membresia';

  // Endpoints de Asistencia y QR del Gimnasio
  static String get asistenciasQrGimnasioUrl => '$baseUrl/api/asistencias/qr-gimnasio';

  // Endpoints del Portal del Socio
  static String get socioDashboardUrl => '$baseUrl/api/socio/dashboard';
  static String get socioCheckinUrl => '$baseUrl/api/socio/checkin';
  static String get socioProgresoUrl => '$baseUrl/api/socio/progreso';
  static String get socioMembresiaUrl => '$baseUrl/api/socio/membresia';
  static String get socioPlanesDisponiblesUrl => '$baseUrl/api/socio/planes-disponibles';
  static String get socioActualizarMembresiaUrl => '$baseUrl/api/socio/membresia/actualizar';
  static String get socioIniciarPagoUrl => '$baseUrl/api/socio/pagos/iniciar';
  static String get socioConfirmarPagoUrl => '$baseUrl/api/socio/pagos/confirmar';
}


