import '../mock/socio_mock_data.dart';
import '../models/socio_mock_models.dart';
import '../services/socio_dashboard_service.dart';

/// Contrato abstracto para la consulta y gestión de membresías y pagos
abstract class IMembresiaRepository {
  /// Obtiene los datos detallados de la membresía del socio
  Future<Map<String, dynamic>?> getMiMembresia();

  /// Obtiene el historial de pagos del socio
  Future<List<PagoItemModel>> getHistorialPagos();

  /// Obtiene el perfil de membresía básico
  Future<SocioProfileModel> getPerfilMembresia();
}

/// Implementación concreta del repositorio de membresías.
class MembresiaRepository implements IMembresiaRepository {
  static final MembresiaRepository _instance = MembresiaRepository._internal();
  factory MembresiaRepository() => _instance;
  static MembresiaRepository get instance => _instance;

  MembresiaRepository._internal();

  final SocioDashboardService _service = SocioDashboardService();
  final SocioMockData _mockData = SocioMockData();

  @override
  Future<Map<String, dynamic>?> getMiMembresia() async {
    return _service.getMiMembresia();
  }

  @override
  Future<List<PagoItemModel>> getHistorialPagos() async {
    await Future.microtask(() {});
    return List.unmodifiable(_mockData.pagos);
  }

  @override
  Future<SocioProfileModel> getPerfilMembresia() async {
    await Future.microtask(() {});
    return _mockData.profile;
  }
}

