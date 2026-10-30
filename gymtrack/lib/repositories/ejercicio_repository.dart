import '../models/ejercicio_model.dart';
import '../services/ejercicio_service.dart';

/// Contrato abstracto para la capa de datos de Ejercicios
abstract class IEjercicioRepository {
  /// Lista de ejercicios para administración / dueño
  Future<List<EjercicioModel>> getEjercicios({String? grupoMuscular, String? search});

  /// Lista de ejercicios disponibles para el socio (del gimnasio y propios)
  Future<List<EjercicioModel>> getEjerciciosSocio({
    String origen = 'todos',
    String? grupoMuscular,
    String? search,
  });

  /// Crea un nuevo ejercicio personalizado propio del socio
  Future<EjercicioModel?> crearEjercicioSocio({
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  });

  /// Actualiza un ejercicio propio
  Future<bool> actualizarEjercicioSocio({
    required int idEjercicio,
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  });

  /// Elimina un ejercicio propio
  Future<bool> eliminarEjercicioSocio(int idEjercicio);
}

/// Implementación concreta del repositorio de ejercicios.
/// Conecta la UI con el servicio de ejercicios y su fallback de datos dinámicos.
class EjercicioRepository implements IEjercicioRepository {
  static final EjercicioRepository _instance = EjercicioRepository._internal();
  factory EjercicioRepository() => _instance;
  static EjercicioRepository get instance => _instance;

  EjercicioRepository._internal();

  final EjercicioService _service = EjercicioService();

  @override
  Future<List<EjercicioModel>> getEjercicios({String? grupoMuscular, String? search}) async {
    return _service.getEjercicios(
      grupoMuscular: grupoMuscular,
      search: search,
    );
  }

  @override
  Future<List<EjercicioModel>> getEjerciciosSocio({
    String origen = 'todos',
    String? grupoMuscular,
    String? search,
  }) async {
    return _service.getEjerciciosSocio(
      origen: origen,
      grupoMuscular: grupoMuscular,
      search: search,
    );
  }

  @override
  Future<EjercicioModel?> crearEjercicioSocio({
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  }) async {
    return _service.crearEjercicioSocio(
      nombre: nombre,
      grupoMuscular: grupoMuscular,
      descripcion: descripcion,
      dificultad: dificultad,
    );
  }

  @override
  Future<bool> actualizarEjercicioSocio({
    required int idEjercicio,
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  }) async {
    return _service.actualizarEjercicioSocio(
      idEjercicio: idEjercicio,
      nombre: nombre,
      grupoMuscular: grupoMuscular,
      descripcion: descripcion,
      dificultad: dificultad,
    );
  }

  @override
  Future<bool> eliminarEjercicioSocio(int idEjercicio) async {
    return _service.eliminarEjercicioSocio(idEjercicio);
  }
}

