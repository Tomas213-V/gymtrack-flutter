import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ejercicio_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class EjercicioService {
  static final EjercicioService _instance = EjercicioService._internal();
  factory EjercicioService() => _instance;
  EjercicioService._internal();

  Future<List<EjercicioModel>> getEjercicios({
    String? grupoMuscular,
    String? search,
    int limit = 50,
  }) async {
    final token = AuthService().token;
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (grupoMuscular != null && grupoMuscular.isNotEmpty && grupoMuscular.toLowerCase() != 'todos') {
        queryParams['grupo_muscular'] = grupoMuscular;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final uri = Uri.parse(ApiConfig.ejerciciosUrl).replace(queryParameters: queryParams);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = (data is Map && data['datos'] != null)
            ? data['datos'] as List
            : (data is List ? data : []);

        return rawList
            .map((e) => EjercicioModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<bool> createEjercicio({
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.ejerciciosUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'nombre': nombre.trim(),
              'grupo_muscular': grupoMuscular,
              'descripcion': descripcion?.trim(),
              'dificultad': dificultad,
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEjercicio({
    required int idEjercicio,
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.ejerciciosUrl}/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode({
              'nombre': nombre.trim(),
              'grupo_muscular': grupoMuscular,
              'descripcion': descripcion?.trim(),
              'dificultad': dificultad,
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEjercicio(int idEjercicio) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.ejerciciosUrl}/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================================
  // MÓDULO SOCIO: EJERCICIOS DEL GIMNASIO Y PROPIOS
  // ==========================================================================

  /// Obtiene los ejercicios disponibles para el socio (del gimnasio y propios).
  Future<List<EjercicioModel>> getEjerciciosSocio({
    String origen = 'todos',
    String? grupoMuscular,
    String? search,
  }) async {
    final token = AuthService().token;
    try {
      final queryParams = <String, String>{
        'origen': origen,
      };
      if (grupoMuscular != null &&
          grupoMuscular.isNotEmpty &&
          grupoMuscular.toLowerCase() != 'todos') {
        queryParams['grupo_muscular'] = grupoMuscular;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final uri = Uri.parse(ApiConfig.socioEjerciciosUrl).replace(queryParameters: queryParams);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List rawList = decoded is List
            ? decoded
            : (decoded is Map && decoded['datos'] is List ? decoded['datos'] : []);

        return rawList
            .map((e) => EjercicioModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Fallback con ejercicios locales si no hay conexión o sesión activa
    return _getEjerciciosSocioFallback(origen: origen, grupoMuscular: grupoMuscular, search: search);
  }

  /// Crea un nuevo ejercicio personalizado propio del socio.
  Future<EjercicioModel?> crearEjercicioSocio({
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.socioEjerciciosUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'nombre': nombre.trim(),
              'grupo_muscular': grupoMuscular ?? 'General',
              'descripcion': descripcion?.trim(),
              'dificultad': dificultad ?? 'Intermedia',
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data['ejercicio'] != null) {
          return EjercicioModel.fromJson(data['ejercicio'] as Map<String, dynamic>);
        }
        return EjercicioModel(
          idEjercicio: DateTime.now().millisecondsSinceEpoch,
          nombre: nombre,
          grupoMuscular: grupoMuscular,
          descripcion: descripcion,
          dificultad: dificultad,
          esPropio: true,
          esGimnasio: false,
          puedeEditar: true,
          puedeEliminar: true,
        );
      }
    } catch (_) {}

    return null;
  }

  /// Actualiza un ejercicio propio del socio.
  Future<bool> actualizarEjercicioSocio({
    required int idEjercicio,
    required String nombre,
    String? grupoMuscular,
    String? descripcion,
    String? dificultad,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.socioEjerciciosUrl}/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode({
              'nombre': nombre.trim(),
              'grupo_muscular': grupoMuscular,
              'descripcion': descripcion?.trim(),
              'dificultad': dificultad,
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Elimina un ejercicio propio del socio.
  Future<bool> eliminarEjercicioSocio(int idEjercicio) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.socioEjerciciosUrl}/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  List<EjercicioModel> _getEjerciciosSocioFallback({
    String origen = 'todos',
    String? grupoMuscular,
    String? search,
  }) {
    final all = [
      EjercicioModel(
        idEjercicio: 101,
        nombre: 'Press de banca plano',
        grupoMuscular: 'Pecho',
        descripcion: 'Ejercicio básico multiarticular de empuje para pectorales.',
        dificultad: 'Intermedia',
        esPropio: false,
        esGimnasio: true,
        origen: 'Gimnasio',
      ),
      EjercicioModel(
        idEjercicio: 102,
        nombre: 'Sentadilla trasera',
        grupoMuscular: 'Piernas',
        descripcion: 'Sentadilla con barra tras nuca para cuádriceps y glúteos.',
        dificultad: 'Avanzada',
        esPropio: false,
        esGimnasio: true,
        origen: 'Gimnasio',
      ),
      EjercicioModel(
        idEjercicio: 103,
        nombre: 'Dominadas pronas',
        grupoMuscular: 'Espalda',
        descripcion: 'Tracción vertical con agarre prono abierto.',
        dificultad: 'Intermedia',
        esPropio: false,
        esGimnasio: true,
        origen: 'Gimnasio',
      ),
      EjercicioModel(
        idEjercicio: 104,
        nombre: 'Press Militar con barra',
        grupoMuscular: 'Hombros',
        descripcion: 'Empuje vertical por delante de la cabeza.',
        dificultad: 'Intermedia',
        esPropio: false,
        esGimnasio: true,
        origen: 'Gimnasio',
      ),
      EjercicioModel(
        idEjercicio: 201,
        nombre: 'Curl Martillo 21s',
        grupoMuscular: 'Brazos',
        descripcion: 'Variante propia de 21 repeticiones con agarre neutro.',
        dificultad: 'Intermedia',
        esPropio: true,
        esGimnasio: false,
        puedeEditar: true,
        puedeEliminar: true,
        origen: 'Mi ejercicio',
      ),
      EjercicioModel(
        idEjercicio: 202,
        nombre: 'Elevaciones laterales drop-set',
        grupoMuscular: 'Hombros',
        descripcion: '3 series descendentes de peso al fallo.',
        dificultad: 'Avanzada',
        esPropio: true,
        esGimnasio: false,
        puedeEditar: true,
        puedeEliminar: true,
        origen: 'Mi ejercicio',
      ),
    ];

    return all.where((e) {
      if (origen == 'gimnasio' && e.esPropio) return false;
      if (origen == 'propio' && !e.esPropio) return false;
      if (grupoMuscular != null &&
          grupoMuscular.isNotEmpty &&
          grupoMuscular.toLowerCase() != 'todos') {
        if (!(e.grupoMuscular?.toLowerCase().contains(grupoMuscular.toLowerCase()) ?? false)) {
          return false;
        }
      }
      if (search != null && search.trim().isNotEmpty) {
        if (!e.nombre.toLowerCase().contains(search.trim().toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
