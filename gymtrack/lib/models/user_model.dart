class GymModel {
  final dynamic idGimnasio;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? estado;

  GymModel({
    required this.idGimnasio,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.email,
    this.estado,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      idGimnasio: json['id_gimnasio'],
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'],
      telefono: json['telefono'],
      email: json['email'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_gimnasio': idGimnasio,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'estado': estado,
    };
  }
}

class UserModel {
  final dynamic idUsuario;
  final String nombre;
  final String apellido;
  final String email;
  final String? rol;
  final String? estado;
  final String? fechaCreacion;
  final GymModel? gimnasio;

  UserModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.rol,
    this.estado,
    this.fechaCreacion,
    this.gimnasio,
  });

  String get fullName => '$nombre $apellido'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'],
      estado: json['estado'],
      fechaCreacion: json['fecha_creacion'],
      gimnasio: json['gimnasio'] != null && json['gimnasio'] is Map<String, dynamic>
          ? GymModel.fromJson(json['gimnasio'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'estado': estado,
      'fecha_creacion': fechaCreacion,
      'gimnasio': gimnasio?.toJson(),
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;
  final String? error;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.error,
  });
}
