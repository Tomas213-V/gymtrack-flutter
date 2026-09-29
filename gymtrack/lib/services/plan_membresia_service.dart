import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan_membresia_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PlanMembresiaService {
  static final PlanMembresiaService _instance = PlanMembresiaService._internal();
  factory PlanMembresiaService() => _instance;
  PlanMembresiaService._internal();

  Future<List<PlanMembresiaModel>> getPlanes({String? estado}) async {
    final token = AuthService().token;
    try {
      final queryParams = <String, String>{};
      if (estado != null && estado.isNotEmpty && estado.toLowerCase() != 'todos') {
        queryParams['estado'] = estado;
      }

      final uri = Uri.parse(ApiConfig.planesMembresiaUrl).replace(
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
        final rawList = data['planes'] as List? ?? [];
        return rawList
            .map((e) => PlanMembresiaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<bool> createPlan({
    required String nombre,
    required double precio,
    required int duracionDias,
    String estado = 'activo',
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.planesMembresiaUrl);
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
              'precio': precio,
              'duracion_dias': duracionDias,
              'estado': estado,
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePlan({
    required int idPlan,
    required String nombre,
    required double precio,
    required int duracionDias,
    required String estado,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.planesMembresiaUrl}/$idPlan');
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
              'precio': precio,
              'duracion_dias': duracionDias,
              'estado': estado,
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> desactivarPlan(int idPlan) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.planesMembresiaUrl}/$idPlan/desactivar');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.patch(uri, headers: headers).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
