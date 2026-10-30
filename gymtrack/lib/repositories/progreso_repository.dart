import '../mock/socio_mock_data.dart';
import '../models/socio_mock_models.dart';
import '../services/socio_dashboard_service.dart';

/// Contrato abstracto para la gestión del progreso físico y antropométrico del socio
abstract class IProgresoRepository {
  /// Obtiene los datos del perfil y métricas de peso del socio
  Future<SocioProfileModel> getPerfilProgreso();

  /// Obtiene el historial completo de pesajes y mediciones
  Future<List<ProgresoRegistroModel>> getRegistrosProgreso();

  /// Obtiene los puntos para la representación gráfica de evolución temporal
  Future<List<ProgresoPuntoModel>> getPuntosGrafico();

  /// Registra una nueva medición de peso y medidas corporales
  Future<ProgresoRegistroModel> registrarProgreso({
    required double peso,
    required String fecha,
    required String nota,
    double? pecho,
    double? cintura,
    double? cadera,
    double? brazo,
    DateTime? rawDate,
  });
}

/// Implementación concreta del repositorio de progreso.
/// Centraliza la persistencia local en memoria y la sincronización con el servicio backend.
class ProgresoRepository implements IProgresoRepository {
  static final ProgresoRepository _instance = ProgresoRepository._internal();
  factory ProgresoRepository() => _instance;
  static ProgresoRepository get instance => _instance;

  ProgresoRepository._internal();

  final SocioMockData _dataSource = SocioMockData();
  final SocioDashboardService _backendService = SocioDashboardService();

  @override
  Future<SocioProfileModel> getPerfilProgreso() async {
    await Future.microtask(() {});
    return _dataSource.profile;
  }

  @override
  Future<List<ProgresoRegistroModel>> getRegistrosProgreso() async {
    await Future.microtask(() {});
    return List.unmodifiable(_dataSource.registrosProgreso);
  }

  @override
  Future<List<ProgresoPuntoModel>> getPuntosGrafico() async {
    await Future.microtask(() {});
    return List.unmodifiable(_dataSource.puntosGrafico);
  }

  @override
  Future<ProgresoRegistroModel> registrarProgreso({
    required double peso,
    required String fecha,
    required String nota,
    double? pecho,
    double? cintura,
    double? cadera,
    double? brazo,
    DateTime? rawDate,
  }) async {
    await Future.microtask(() {});

    // 1. Guardar en la fuente de datos local dinámica
    _dataSource.agregarProgreso(
      peso: peso,
      fecha: fecha,
      nota: nota,
      pecho: pecho,
      cintura: cintura,
      cadera: cadera,
      brazo: brazo,
    );

    // 2. Intentar sincronización con el backend si se provee la fecha ISO
    if (rawDate != null) {
      final isoDate = '${rawDate.year}-${rawDate.month.toString().padLeft(2, '0')}-${rawDate.day.toString().padLeft(2, '0')}';
      try {
        await _backendService.registrarProgreso(
          peso: peso,
          observaciones: nota.isNotEmpty ? nota : 'Registro de progreso',
          fecha: isoDate,
        );
      } catch (_) {
        // Fallback offline silencioso
      }
    }

    return _dataSource.registrosProgreso.first;
  }
}

