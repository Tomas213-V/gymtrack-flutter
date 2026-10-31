import '../models/perfil_socio_model.dart';
import '../models/socio_model.dart';
import '../services/socio_service.dart';

/// Contrato abstracto para la gestión de Socios y sus perfiles
abstract class ISocioRepository {
  /// Obtiene estadísticas globales de socios para el panel administrativo
  Future<SocioStatsModel> getStats();

  /// Obtiene listado paginado y filtrado de socios
  Future<Map<String, dynamic>> getSocios({
    int page = 1,
    int limit = 10,
    String? estado,
    String? search,
  });

  /// Obtiene el perfil detallado de un socio
  Future<PerfilSocioModel?> getPerfilSocio({int? idSocio});

  /// Crea un nuevo socio en el gimnasio
  Future<CreateSocioResult> createSocio({
    required String nombre,
    required String apellido,
    required String dni,
    String? telefono,
    String? plan,
    double? precio,
    String? estado,
    String? fechaVencimiento,
  });

  /// Verifica preventivamente si el DNI existe o pertenece a otro gimnasio
  Future<Map<String, dynamic>?> verificarDni(String dni);
}

/// Implementación concreta del repositorio de socios.
class SocioRepository implements ISocioRepository {
  static final SocioRepository _instance = SocioRepository._internal();
  factory SocioRepository() => _instance;
  static SocioRepository get instance => _instance;

  SocioRepository._internal();

  final SocioService _service = SocioService();

  @override
  Future<SocioStatsModel> getStats() async {
    return _service.getStats();
  }

  @override
  Future<Map<String, dynamic>> getSocios({
    int page = 1,
    int limit = 10,
    String? estado,
    String? search,
  }) async {
    return _service.getSocios(
      page: page,
      limit: limit,
      estado: estado ?? 'todos',
      search: search,
    );
  }

  @override
  Future<PerfilSocioModel?> getPerfilSocio({int? idSocio}) async {
    return _service.getPerfilSocio(idSocio: idSocio);
  }

  @override
  Future<CreateSocioResult> createSocio({
    required String nombre,
    required String apellido,
    required String dni,
    String? telefono,
    String? plan,
    double? precio,
    String? estado,
    String? fechaVencimiento,
  }) async {
    return _service.createSocio(
      nombre: nombre,
      apellido: apellido,
      dni: dni,
      telefono: telefono,
      plan: plan,
      precio: precio,
      estado: estado,
      fechaVencimiento: fechaVencimiento,
    );
  }

  @override
  Future<Map<String, dynamic>?> verificarDni(String dni) async {
    return _service.verificarDni(dni);
  }
}
