import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PagoService {
  static final PagoService _instance = PagoService._internal();
  factory PagoService() => _instance;
  PagoService._internal();

  static final List<PagoModel> _demoPagos = [
        PagoModel(
          idPago: 1,
          socioNombre: 'Camila Rodriguez',
          plan: 'Plan Mensual Completo',
          fechaPago: '2026-10-31',
          monto: 18000,
          estado: 'pagado',
          metodoPago: 'Efectivo',
          comprobante: 'COMP-17934812001',
          dniSocio: '41.234.567',
          telefonoSocio: '11-2345-6789',
          fechaVencimiento: '2026-11-30',
        ),
        PagoModel(
          idPago: 2,
          socioNombre: 'Eze Maron',
          plan: 'Plan Básico',
          fechaPago: '2026-10-31',
          monto: 15000,
          estado: 'pagado',
          metodoPago: 'Mercado Pago',
          comprobante: 'COMP-17934803688',
          dniSocio: '123456789',
          telefonoSocio: '987654321',
          emailSocio: 'eze@gmail.com',
          fechaVencimiento: '2026-11-30',
        ),
        PagoModel(
          idPago: 3,
          socioNombre: 'Mocho Gym',
          plan: 'Plan Premium',
          fechaPago: '2026-10-23',
          monto: 22000,
          estado: 'pagado',
          metodoPago: 'Transferencia',
          comprobante: 'COMP-17934789123',
          dniSocio: '38.991.223',
          telefonoSocio: '11-4567-8901',
          fechaVencimiento: '2026-11-23',
        ),
        PagoModel(
          idPago: 4,
          socioNombre: 'Luciano Gracia',
          plan: 'Plan Mensual',
          fechaPago: '2026-10-15',
          monto: 18000,
          estado: 'pendiente',
          metodoPago: 'Efectivo',
          comprobante: 'COMP-17934651982',
          dniSocio: '41.234.567',
          telefonoSocio: '11-2345-6789',
          fechaVencimiento: '2026-11-15',
        ),
        PagoModel(
          idPago: 5,
          socioNombre: 'Nicolás Torres',
          plan: 'Plan Trimestral',
          fechaPago: '2026-09-25',
          monto: 48000,
          estado: 'vencido',
          metodoPago: 'Tarjeta',
          comprobante: 'COMP-17933981241',
          dniSocio: '42.112.980',
          telefonoSocio: '11-8765-4321',
          fechaVencimiento: '2026-10-25',
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
          var list = rawList.map((e) => PagoModel.fromJson(e)).toList();
          if (estado.toLowerCase() != 'todos') {
            list = list.where((p) => p.estado.toLowerCase() == estado.toLowerCase()).toList();
          }
          if (search != null && search.trim().isNotEmpty) {
            final q = search.trim().toLowerCase();
            list = list.where((p) =>
                p.socioNombre.toLowerCase().contains(q) ||
                p.plan.toLowerCase().contains(q)).toList();
          }
          return list;
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
    int? idSocio,
    String? dniSocio,
    String metodoPago = 'Efectivo',
    String estado = 'pagado',
  }) async {
    final token = AuthService().token;
    final currentGymId = AuthService().currentUser?.gimnasio?.idGimnasio;

    try {
      final uri = Uri.parse(ApiConfig.pagosUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final bodyMap = <String, dynamic>{
        'socio_nombre': socioNombre.trim(),
        'nombreSocio': socioNombre.trim(),
        'monto': monto,
        'plan': plan,
        'metodo_pago': metodoPago,
        'estado': estado,
        'fecha_pago': DateTime.now().toIso8601String().split('T')[0],
      };
      if (idSocio != null) {
        bodyMap['id_socio'] = idSocio;
      }
      if (dniSocio != null && dniSocio.trim().isNotEmpty) {
        bodyMap['dniSocio'] = dniSocio.trim();
      }
      if (currentGymId != null) {
        bodyMap['id_gimnasio'] = currentGymId;
      }

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(bodyMap))
          .timeout(const Duration(seconds: 10));

      final success = response.statusCode == 200 || response.statusCode == 201;

      final nuevoPago = PagoModel(
        idPago: DateTime.now().millisecondsSinceEpoch,
        socioNombre: socioNombre.trim(),
        plan: plan,
        fechaPago: DateTime.now().toIso8601String().split('T')[0],
        monto: monto,
        estado: estado,
        metodoPago: metodoPago,
        comprobante: 'COMP-${DateTime.now().millisecondsSinceEpoch}',
        dniSocio: dniSocio,
        fechaVencimiento: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      );
      _demoPagos.insert(0, nuevoPago);

      return success;
    } catch (_) {
      final nuevoPago = PagoModel(
        idPago: DateTime.now().millisecondsSinceEpoch,
        socioNombre: socioNombre.trim(),
        plan: plan,
        fechaPago: DateTime.now().toIso8601String().split('T')[0],
        monto: monto,
        estado: estado,
        metodoPago: metodoPago,
        comprobante: 'COMP-${DateTime.now().millisecondsSinceEpoch}',
        dniSocio: dniSocio,
        fechaVencimiento: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      );
      _demoPagos.insert(0, nuevoPago);
      return true;
    }
  }

  Future<bool> marcarComoPagado(dynamic idPago) async {
    for (int i = 0; i < _demoPagos.length; i++) {
      if (_demoPagos[i].idPago.toString() == idPago.toString()) {
        _demoPagos[i] = _demoPagos[i].copyWith(
          estado: 'pagado',
          fechaPago: DateTime.now().toIso8601String().split('T')[0],
        );
        break;
      }
    }
    return true;
  }
}
