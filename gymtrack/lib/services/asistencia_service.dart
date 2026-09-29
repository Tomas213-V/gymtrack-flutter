import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asistencia_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class AsistenciaService {
  static final AsistenciaService _instance = AsistenciaService._internal();
  factory AsistenciaService() => _instance;
  AsistenciaService._internal();

  Future<Map<String, dynamic>> getAsistencias({
    int page = 1,
    int limit = 15,
    String? search,
    String? desde,
    String? hasta,
  }) async {
    final token = AuthService().token;
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (desde != null && desde.isNotEmpty) {
        queryParams['desde'] = desde;
      }
      if (hasta != null && hasta.isNotEmpty) {
        queryParams['hasta'] = hasta;
      }

      final uri = Uri.parse(ApiConfig.asistenciasUrl).replace(queryParameters: queryParams);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data['asistencias'] as List? ?? [];
        final total = data['total'] as int? ?? rawList.length;

        final items = rawList
            .map((e) => AsistenciaItemModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return {
          'asistencias': items,
          'total': total,
        };
      }
    } catch (_) {}

    return {
      'asistencias': <AsistenciaItemModel>[],
      'total': 0,
    };
  }

  Future<Map<String, dynamic>> registrarAsistencia({
    String? dni,
    int? idSocio,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.asistenciasUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{};
      if (dni != null && dni.trim().isNotEmpty) {
        body['dni'] = dni.trim();
      }
      if (idSocio != null) {
        body['id_socio'] = idSocio;
      }

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AsistenciaItemModel? item;
        if (data['asistencia'] != null) {
          item = AsistenciaItemModel.fromJson(data['asistencia']);
        }
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Ingreso registrado correctamente.',
          'asistencia': item,
        };
      } else {
        return {
          'success': false,
          'mensaje': data['error'] ?? 'No se pudo registrar el ingreso.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }

  Future<bool> checkoutAsistencia(int idAsistencia) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse('${ApiConfig.asistenciasUrl}/$idAsistencia/checkout');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .patch(uri, headers: headers, body: jsonEncode({'estado': 'completado'}))
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<AsistenciaEstadisticasModel> getEstadisticas() async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.asistenciasEstadisticasUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AsistenciaEstadisticasModel.fromJson(data);
      }
    } catch (_) {}

    return AsistenciaEstadisticasModel(
      totalMesActual: 0,
      totalMesAnterior: 0,
      porcentajeCambio: 0,
      tendencia: 'neutral',
    );
  }
}
