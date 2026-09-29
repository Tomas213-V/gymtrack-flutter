import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class GimnasioService {
  static final GimnasioService _instance = GimnasioService._internal();
  factory GimnasioService() => _instance;
  GimnasioService._internal();

  Future<GymModel?> getMiGimnasio() async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.miGimnasioUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['gimnasio'] != null) {
          return GymModel.fromJson(data['gimnasio']);
        }
      }
    } catch (_) {}

    return null;
  }

  Future<bool> actualizarGimnasio({
    required String nombre,
    String? direccion,
    String? telefono,
    String? email,
  }) async {
    final token = AuthService().token;
    try {
      final uri = Uri.parse(ApiConfig.miGimnasioUrl);
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
              'direccion': direccion?.trim(),
              'telefono': telefono?.trim(),
              'email': email?.trim(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
