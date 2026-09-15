import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/socio_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class SocioService {
  static final SocioService _instance = SocioService._internal();
  factory SocioService() => _instance;
  SocioService._internal();

  // Lista demo de respaldo que replica con exactitud los datos de la maqueta
  static List<SocioModel> get _demoSocios => [
        SocioModel(
          idSocio: 1,
          nombre: 'Luciano',
          apellido: 'Gracia',
          dni: '41.234.567',
          telefono: '11 2345 6789',
          estado: 'activo',
          plan: 'Plan Mensual',
          fechaVencimiento: '25 May 2026',
        ),
        SocioModel(
          idSocio: 2,
          nombre: 'Camila',
          apellido: 'Rodriguez',
          dni: '41.234.567',
          telefono: '11 2345 6789',
          estado: 'pendiente',
          plan: 'Plan Mensual',
          fechaVencimiento: '26 May 2026',
        ),
        SocioModel(
          idSocio: 3,
          nombre: 'Nicolás',
          apellido: 'Torres',
          dni: '41.234.567',
          telefono: '11 2345 6789',
          estado: 'activo',
          plan: 'Plan Trimestral',
          fechaVencimiento: '25 May 2026',
        ),
        SocioModel(
          idSocio: 4,
          nombre: 'Martina',
          apellido: 'Lopez',
          dni: '41.234.567',
          telefono: '11 2345 6789',
          estado: 'inactivo',
          plan: 'Plan Mensual',
          fechaVencimiento: 'Vencido el 15 abr 2026',
        ),
        SocioModel(
          idSocio: 5,
          nombre: 'Valentina',
          apellido: 'Gomez',
          dni: '41.234.567',
          telefono: '11 2345 6789',
          estado: 'activo',
          plan: 'Plan Mensual',
          fechaVencimiento: '25 May 2026',
        ),
        SocioModel(
          idSocio: 6,
          nombre: 'Lucas',
          apellido: 'Martinez',
          dni: '39.876.543',
          telefono: '11 9876 5432',
          estado: 'activo',
          plan: 'Plan Anual',
          fechaVencimiento: '10 Dic 2026',
        ),
      ];

  Future<Map<String, dynamic>> getSocios({
    int page = 1,
    int limit = 6,
    String estado = 'todos',
    String? search,
  }) async {
    final token = AuthService().token;

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (estado.isNotEmpty && estado.toLowerCase() != 'todos') {
        queryParams['estado'] = estado.toLowerCase();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final uri = Uri.parse(ApiConfig.sociosUrl).replace(queryParameters: queryParams);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data['socios'] as List? ?? [];
        final total = data['total'] as int? ?? rawList.length;
        final totalPages = data['totalPages'] as int? ?? 1;

        if (rawList.isNotEmpty) {
          final socios = rawList.map((e) => SocioModel.fromJson(e)).toList();
          return {
            'socios': socios,
            'total': total,
            'totalPages': totalPages,
          };
        }
      }
    } catch (_) {
      // Fallback a demo data
    }

    // Filtrar la lista de demostración para una experiencia de usuario perfecta
    var filtered = _demoSocios;
    if (estado.toLowerCase() != 'todos') {
      filtered = filtered.where((s) => s.estado.toLowerCase() == estado.toLowerCase()).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((s) =>
          s.nombreCompleto.toLowerCase().contains(q) ||
          s.dni.toLowerCase().contains(q) ||
          (s.telefono != null && s.telefono!.toLowerCase().contains(q))).toList();
    }

    return {
      'socios': filtered,
      'total': 128,
      'totalPages': 3,
    };
  }

  Future<SocioStatsModel> getStats() async {
    final token = AuthService().token;

    try {
      final uri = Uri.parse(ApiConfig.sociosStatsUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SocioStatsModel.fromJson(data);
      }
    } catch (_) {
      // Fallback
    }

    return SocioStatsModel.defaultStats();
  }

  Future<bool> createSocio({
    required String nombre,
    required String apellido,
    required String dni,
    String? telefono,
    String? plan,
    double? precio,
    String? estado,
    String? fechaVencimiento,
  }) async {
    final token = AuthService().token;

    try {
      final uri = Uri.parse(ApiConfig.sociosUrl);
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
              'apellido': apellido.trim(),
              'dni': dni.trim(),
              'telefono': telefono?.trim(),
              'plan': plan ?? 'Plan Mensual',
              'precio': precio ?? 18000,
              'estado': estado ?? 'activo',
              'fecha_vencimiento': fechaVencimiento,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
