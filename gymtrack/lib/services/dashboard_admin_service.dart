import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_admin_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class DashboardAdminService {
  static final DashboardAdminService _instance = DashboardAdminService._internal();
  factory DashboardAdminService() => _instance;
  DashboardAdminService._internal();

  Future<DashboardAdminModel> getDashboardAdmin({int? idGimnasio}) async {
    final token = AuthService().token;
    final currentUser = AuthService().currentUser;
    final gymId = idGimnasio ?? currentUser?.gimnasio?.idGimnasio;

    try {
      final queryParams = <String, String>{};
      if (gymId != null) {
        queryParams['id_gimnasio'] = gymId.toString();
      }

      final uri = Uri.parse(ApiConfig.dashboardAdminUrl).replace(
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
        if (data is Map<String, dynamic>) {
          return DashboardAdminModel.fromJson(data);
        }
      }
    } catch (_) {
      // Fallback a mock en caso de timeout o backend no disponible
    }

    return DashboardAdminModel.defaultMock();
  }
}
