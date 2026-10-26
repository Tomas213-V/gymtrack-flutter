// ==============================================================================
// SERVICIO DEL PORTAL DEL SOCIO (GYMTRACK)
// ==============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/socio_dashboard_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class SocioDashboardService {
  static final SocioDashboardService _instance = SocioDashboardService._internal();
  factory SocioDashboardService() => _instance;
  SocioDashboardService._internal();

  Map<String, String> _buildHeaders() {
    final token = AuthService().token;
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 1. Obtiene la información completa del Dashboard del socio
  Future<SocioDashboardModel?> getDashboard() async {
    try {
      final uri = Uri.parse(ApiConfig.socioDashboardUrl);
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SocioDashboardModel.fromJson(data);
      }
    } catch (e) {
      // Ignorar para fallback
    }
    return null;
  }

  /// 2. Registra el check-in de asistencia (opcionalmente con código QR)
  Future<Map<String, dynamic>> registrarCheckin({
    String? qrData,
    String? codigoQr,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.socioCheckinUrl);
      final body = <String, dynamic>{};
      if (qrData != null && qrData.isNotEmpty) {
        body['qr_data'] = qrData;
      }
      if (codigoQr != null && codigoQr.isNotEmpty) {
        body['codigo_qr'] = codigoQr;
      }

      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? '¡Asistencia registrada con éxito!',
          'asistencia': data['asistencia'],
          'ya_registrado': data['ya_registrado'] == true,
          'metodo': data['metodo'] ?? (qrData != null ? 'qr' : 'manual'),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'No se pudo registrar la asistencia.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión al registrar asistencia: $e',
      };
    }
  }

  /// 3. Carga un nuevo registro de peso / progreso
  Future<Map<String, dynamic>> registrarProgreso({
    required double peso,
    String? observaciones,
    String? fecha,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.socioProgresoUrl);
      final body = <String, dynamic>{
        'peso': peso,
      };
      if (observaciones != null && observaciones.isNotEmpty) {
        body['observaciones'] = observaciones;
      }
      if (fecha != null && fecha.isNotEmpty) {
        body['fecha'] = fecha;
      }

      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? '¡Progreso registrado con éxito!',
          'progreso': data['progreso'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Error al registrar el progreso.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// 4. Obtiene información detallada de la membresía e historial de pagos
  Future<Map<String, dynamic>?> getMiMembresia() async {
    try {
      final uri = Uri.parse(ApiConfig.socioMembresiaUrl);
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 5. Obtiene los planes disponibles del gimnasio
  Future<List<PlanDisponibleModel>> getPlanesDisponibles() async {
    try {
      final uri = Uri.parse(ApiConfig.socioPlanesDisponiblesUrl);
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawPlanes = data['planes'] as List? ?? [];
        return rawPlanes
            .map((p) => PlanDisponibleModel.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// 6. Inicia una sesión de pago digital (Mercado Pago o Ualá)
  Future<Map<String, dynamic>> iniciarPago({
    required int idPlanMembresia,
    String metodoPago = 'mercadopago',
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.socioIniciarPagoUrl);
      final body = {
        'id_plan_membresia': idPlanMembresia,
        'metodo_pago': metodoPago,
      };

      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'mensaje': data['mensaje'],
          'checkout': data['checkout'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Error al iniciar sesión de pago.',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// 7. Confirma el pago de la membresía y la activa
  Future<Map<String, dynamic>> confirmarPago({
    required int idPlanMembresia,
    double? monto,
    String metodoPago = 'mercadopago',
    String? comprobante,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.socioConfirmarPagoUrl);
      final body = <String, dynamic>{
        'id_plan_membresia': idPlanMembresia,
        'metodo_pago': metodoPago,
      };
      if (monto != null) body['monto'] = monto;
      if (comprobante != null) body['comprobante'] = comprobante;

      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? '¡Pago confirmado con éxito!',
          'membresia': data['membresia'],
          'pago': data['pago'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Error al confirmar el pago.',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
