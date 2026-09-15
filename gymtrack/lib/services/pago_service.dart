import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PagoService {
  static final PagoService _instance = PagoService._internal();
  factory PagoService() => _instance;
  PagoService._internal();

  static List<PagoModel> get _demoPagos => [
        PagoModel(
          idPago: 1,
          socioNombre: 'Juan Perez',
          plan: 'Plan Premium',
          fechaPago: '18/05/2026',
          monto: 18000,
          estado: 'pagado',
          metodoPago: 'Efectivo',
        ),
        PagoModel(
          idPago: 2,
          socioNombre: 'María Gómez',
          plan: 'Plan Básico',
          fechaPago: '18/05/2026',
          monto: 18000,
          estado: 'pagado',
          metodoPago: 'Transferencia',
        ),
        PagoModel(
          idPago: 3,
          socioNombre: 'Carlos López',
          plan: 'Plan Premium',
          fechaPago: '17/05/2026',
          monto: 18000,
          estado: 'pendiente',
          metodoPago: 'Efectivo',
        ),
        PagoModel(
          idPago: 4,
          socioNombre: 'Ana Rodriguez',
          plan: 'Plan Basico',
          fechaPago: '15/05/2026',
          monto: 18000,
          estado: 'vencido',
          metodoPago: 'Tarjeta',
        ),
      ];

  Future<List<PagoModel>> getPagos({
    int page = 1,
    int limit = 10,
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

      final uri = Uri.parse(ApiConfig.pagosUrl).replace(queryParameters: queryParams);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList = data['datos'] as List? ?? [];
        if (rawList.isNotEmpty) {
          return rawList.map((e) => PagoModel.fromJson(e)).toList();
        }
      }
    } catch (_) {
      // Fallback
    }

    var filtered = _demoPagos;
    if (estado.toLowerCase() != 'todos') {
      filtered = filtered.where((p) => p.estado.toLowerCase() == estado.toLowerCase()).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((p) =>
          p.socioNombre.toLowerCase().contains(q) ||
          p.plan.toLowerCase().contains(q)).toList();
    }

    return filtered;
  }

  Future<ResumenPagosModel> getResumen() async {
    final token = AuthService().token;

    try {
      final uri = Uri.parse(ApiConfig.pagosResumenUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ResumenPagosModel.fromJson(data);
      }
    } catch (_) {
      // Fallback
    }

    return ResumenPagosModel.defaultResumen();
  }

  Future<bool> registrarPago({
    required String socioNombre,
    required double monto,
    required String plan,
    String metodoPago = 'Efectivo',
    String estado = 'pagado',
  }) async {
    final token = AuthService().token;

    try {
      final uri = Uri.parse(ApiConfig.pagosUrl);
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
              'socio_nombre': socioNombre.trim(),
              'monto': monto,
              'plan': plan,
              'metodo_pago': metodoPago,
              'estado': estado,
              'fecha_pago': DateTime.now().toIso8601String().split('T')[0],
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
