import '../mock/socio_mock_data.dart';
import '../models/rutina_model.dart' as backend_rutina;
import '../models/socio_mock_models.dart' as mock_models;
import '../services/rutina_service.dart';

/// Contrato abstracto para la gestión de Rutinas de entrenamiento
abstract class IRutinaRepository {
  /// Obtiene la rutina asignada al socio desde los datos locales dinámicos
  Future<mock_models.RutinaModel> getRutinaSocio();

  /// Marca o desmarca un ejercicio de la rutina como completado
  Future<void> toggleEjercicioCompletado(String id);

  /// Obtiene programas predefinidos del gimnasio desde el backend
  Future<List<backend_rutina.RutinaModel>> getProgramasGym();

  /// Obtiene las rutinas asignadas al socio desde el backend
  Future<List<backend_rutina.RutinaModel>> getRutinasBackend({int? idSocio});
}

/// Implementación concreta del repositorio de rutinas.
class RutinaRepository implements IRutinaRepository {
  static final RutinaRepository _instance = RutinaRepository._internal();
  factory RutinaRepository() => _instance;
  static RutinaRepository get instance => _instance;

  RutinaRepository._internal();

  final SocioMockData _mockData = SocioMockData();
  final RutinaService _rutinaService = RutinaService();

  @override
  Future<mock_models.RutinaModel> getRutinaSocio() async {
    await Future.microtask(() {});
    return _mockData.rutina;
  }

  @override
  Future<void> toggleEjercicioCompletado(String id) async {
    await Future.microtask(() {});
    _mockData.toggleEjercicioCompletado(id);
  }

  @override
  Future<List<backend_rutina.RutinaModel>> getProgramasGym() async {
    return _rutinaService.fetchRutinasOfrecidasGym();
  }

  @override
  Future<List<backend_rutina.RutinaModel>> getRutinasBackend({int? idSocio}) async {
    return _rutinaService.getRutinas(idSocio: idSocio);
  }
}

