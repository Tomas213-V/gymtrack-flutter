import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Estado en memoria de la sesión actual
  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;

  void logout() {
    _currentUser = null;
    _token = null;
  }

  /// Inicia sesión enviando email y contraseña al backend
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.loginUrl);
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'contrasena': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'] as String?;
        if (data['usuario'] != null) {
          _currentUser = UserModel.fromJson(data['usuario']);
        }
        return AuthResponse(
          success: true,
          message: data['mensaje'] ?? 'Inicio de sesión exitoso.',
          token: _token,
          user: _currentUser,
        );
      } else {
        final errorMsg = data['error'] ?? 'Credenciales inválidas o error en el servidor.';
        return AuthResponse(
          success: false,
          message: errorMsg,
          error: errorMsg,
        );
      }
    } on SocketException {
      return AuthResponse(
        success: false,
        message: 'No se pudo conectar con el servidor en ${ApiConfig.baseUrl}. Verifica que el backend esté iniciado en el puerto 3000.',
        error: 'Error de conexión',
      );
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: 'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
        error: 'Tiempo de espera agotado',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Ocurrió un error inesperado: $e',
        error: e.toString(),
      );
    }
  }

  /// Registra un nuevo usuario dueño (y opcionalmente su gimnasio)
  Future<AuthResponse> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? nombreGimnasio,
    String? direccion,
    String? telefono,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.registerUrl);
      final bodyData = <String, dynamic>{
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'email': email.trim(),
        'contrasena': password,
      };

      if (nombreGimnasio != null && nombreGimnasio.trim().isNotEmpty) {
        bodyData['nombreGimnasio'] = nombreGimnasio.trim();
      }
      if (direccion != null && direccion.trim().isNotEmpty) {
        bodyData['direccion'] = direccion.trim();
      }
      if (telefono != null && telefono.trim().isNotEmpty) {
        bodyData['telefono'] = telefono.trim();
      }

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyData),
          )
          .timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'] as String?;
        if (data['usuario'] != null) {
          _currentUser = UserModel.fromJson(data['usuario']);
        }
        return AuthResponse(
          success: true,
          message: data['mensaje'] ?? 'Registro completado con éxito.',
          token: _token,
          user: _currentUser,
        );
      } else {
        final errorMsg = data['error'] ?? 'No se pudo completar el registro.';
        return AuthResponse(
          success: false,
          message: errorMsg,
          error: errorMsg,
        );
      }
    } on SocketException {
      return AuthResponse(
        success: false,
        message: 'No se pudo conectar con el servidor en ${ApiConfig.baseUrl}. Verifica que el backend esté iniciado en el puerto 3000.',
        error: 'Error de conexión',
      );
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: 'El servidor tardó demasiado en responder al procesar el registro.',
        error: 'Tiempo de espera agotado',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Ocurrió un error inesperado al registrarse: $e',
        error: e.toString(),
      );
    }
  }

  /// Consulta el perfil del usuario actual utilizando el Bearer token
  Future<UserModel?> getMe() async {
    if (_token == null) return null;

    try {
      final url = Uri.parse(ApiConfig.meUrl);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['usuario'] != null) {
          _currentUser = UserModel.fromJson(data['usuario']);
          return _currentUser;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Registra el gimnasio del usuario autenticado
  Future<AuthResponse> registrarGimnasio({
    required String nombre,
    String? direccion,
    String? telefono,
    String? email,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.gimnasiosUrl);
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final bodyData = <String, dynamic>{
        'nombre': nombre.trim(),
      };
      if (_currentUser?.idUsuario != null) {
        bodyData['id_usuario'] = _currentUser!.idUsuario;
      }
      if (direccion != null && direccion.trim().isNotEmpty) {
        bodyData['direccion'] = direccion.trim();
      }
      if (telefono != null && telefono.trim().isNotEmpty) {
        bodyData['telefono'] = telefono.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        bodyData['email'] = email.trim();
      }

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(bodyData),
          )
          .timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data['token'] != null) {
          _token = data['token'] as String;
        }

        GymModel? newGym;
        if (data['gimnasio'] != null) {
          newGym = GymModel.fromJson(data['gimnasio']);
        }

        if (_currentUser != null && newGym != null) {
          _currentUser = UserModel(
            idUsuario: _currentUser!.idUsuario,
            nombre: _currentUser!.nombre,
            apellido: _currentUser!.apellido,
            email: _currentUser!.email,
            rol: _currentUser!.rol,
            estado: _currentUser!.estado,
            fechaCreacion: _currentUser!.fechaCreacion,
            gimnasio: newGym,
          );
        }

        return AuthResponse(
          success: true,
          message: data['mensaje'] ?? 'Gimnasio registrado exitosamente.',
          token: _token,
          user: _currentUser,
        );
      } else {
        final errorMsg = data['error'] ?? 'No se pudo registrar el gimnasio.';
        return AuthResponse(
          success: false,
          message: errorMsg,
          error: errorMsg,
        );
      }
    } on SocketException {
      return AuthResponse(
        success: false,
        message: 'No se pudo conectar con el servidor en ${ApiConfig.baseUrl}. Verifica la conexión.',
        error: 'Error de conexión',
      );
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: 'Tiempo de espera agotado al registrar el gimnasio.',
        error: 'Timeout',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error al registrar el gimnasio: $e',
        error: e.toString(),
      );
    }
  }

  /// Verifica si el usuario actual tiene un gimnasio asignado
  Future<GymModel?> verificarGimnasio() async {
    if (_token == null) return null;

    try {
      final url = Uri.parse(ApiConfig.miGimnasioUrl);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tieneGimnasio'] == true && data['gimnasio'] != null) {
          final gym = GymModel.fromJson(data['gimnasio']);
          if (_currentUser != null) {
            _currentUser = UserModel(
              idUsuario: _currentUser!.idUsuario,
              nombre: _currentUser!.nombre,
              apellido: _currentUser!.apellido,
              email: _currentUser!.email,
              rol: _currentUser!.rol,
              estado: _currentUser!.estado,
              fechaCreacion: _currentUser!.fechaCreacion,
              gimnasio: gym,
            );
          }
          return gym;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
