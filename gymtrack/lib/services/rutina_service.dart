import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rutina_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class RutinaService {
  static final RutinaService _instance = RutinaService._internal();
  factory RutinaService() => _instance;
  RutinaService._internal();

  Future<List<RutinaModel>> getRutinas({
    String? search,
    String? estado,
    int? idSocio,
  }) async {
    final token = AuthService().token;
    try {
      final queryParams = <String, String>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (estado != null && estado.isNotEmpty && estado.toLowerCase() != 'todos') {
        queryParams['estado'] = estado;
      }
      if (idSocio != null) {
        queryParams['id_socio'] = idSocio.toString();
      }

      final uri = Uri.parse(ApiConfig.rutinasUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data is List ? data : [];
        return rawList
            .map((e) => RutinaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<RutinaModel?> getRutinaById(int idRutina) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RutinaModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createRutina({
    required String nombre,
    String? descripcion,
    required int idSocio,
    String? fechaInicio,
    String? fechaFin,
    String estado = 'activo',
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.rutinasUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final now = DateTime.now();
      final defaultInicio = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'nombre': nombre.trim(),
              'descripcion': descripcion?.trim(),
              'id_socio': idSocio,
              'fecha_inicio': fechaInicio ?? defaultInicio,
              'fecha_fin': fechaFin,
              'estado': estado,
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateRutina({
    required int idRutina,
    required String nombre,
    String? descripcion,
    required String estado,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'nombre': nombre.trim(),
        'descripcion': descripcion?.trim(),
        'estado': estado,
      };
      if (fechaInicio != null) body['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) body['fecha_fin'] = fechaFin;

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));


      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRutina(int idRutina) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina');
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

  Future<bool> addEjercicioToRutina({
    required int idRutina,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    double? peso,
    int? descanso,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/ejercicios');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'id_ejercicio': idEjercicio,
        'series': series,
        'repeticiones': repeticiones,
      };
      if (peso != null) body['peso'] = peso;
      if (descanso != null) body['descanso'] = descanso;

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));


      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeEjercicioFromRutina({
    required int idRutina,
    required int idEjercicio,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/ejercicios/$idEjercicio');
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

  /// Obtiene los programas oficiales del gimnasio ofrecidos a todos los socios
  Future<List<RutinaModel>> fetchRutinasOfrecidasGym() async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.rutinasOfrecidasGymUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data is List ? data : (data is Map && data['rutinas'] != null ? data['rutinas'] as List : []);
        return rawList
            .map((e) => RutinaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Adopta/clona un programa oficial del gimnasio a las rutinas personales del socio
  Future<Map<String, dynamic>> adoptarRutinaGym({
    int? idPlantilla,
    int? idSocio,
    String? nombrePersonalizado,
    Map<String, dynamic>? plantilla,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.rutinasAdoptarUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{};
      if (idPlantilla != null) body['id_plantilla'] = idPlantilla;
      if (idSocio != null) body['id_socio'] = idSocio;
      if (nombrePersonalizado != null) body['nombre_personalizado'] = nombrePersonalizado;
      if (plantilla != null) body['plantilla'] = plantilla;

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? data['mensaje'] ?? '¡Rutina adoptada con éxito!',
          'rutina': data['rutina'] != null ? RutinaModel.fromJson(data['rutina']) : null,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? data['detail'] ?? 'No se pudo adoptar la rutina.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Establece una rutina como la rutina activa principal del socio
  Future<bool> activarRutina(int idRutina) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/activar');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(uri, headers: headers).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Actualiza series, repeticiones, peso o descanso de un ejercicio en una rutina
  Future<bool> updateEjercicioEnRutina({
    required int idRutina,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    double? peso,
    int? descanso,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.rutinasUrl}/$idRutina/ejercicios/$idEjercicio');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'series': series,
        'repeticiones': repeticiones,
      };
      if (peso != null) body['peso'] = peso;
      if (descanso != null) body['descanso'] = descanso;

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
