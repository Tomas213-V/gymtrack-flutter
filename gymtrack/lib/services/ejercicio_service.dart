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
}
