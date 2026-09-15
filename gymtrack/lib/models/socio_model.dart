class SocioModel {
  final dynamic idSocio;
  final dynamic idUsuario;
  final String nombre;
  final String apellido;
  final String dni;
  final String? telefono;
  final String estado; // 'activo', 'pendiente', 'inactivo'
  final String? plan;
  final double? precio;
  final String? fechaVencimiento;
  final String? fechaAlta;

  SocioModel({
    required this.idSocio,
    this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.dni,
    this.telefono,
    this.estado = 'activo',
    this.plan,
    this.precio,
    this.fechaVencimiento,
    this.fechaAlta,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  bool get isActivo => estado.toLowerCase() == 'activo';
  bool get isPendiente => estado.toLowerCase() == 'pendiente';
  bool get isInactivo => estado.toLowerCase() == 'inactivo';

  factory SocioModel.fromJson(Map<String, dynamic> json) {
    String nombre = '';
    String apellido = '';

    if (json['usuario'] != null && json['usuario'] is Map<String, dynamic>) {
      nombre = json['usuario']['nombre'] ?? '';
      apellido = json['usuario']['apellido'] ?? '';
    } else {
      nombre = json['nombre'] ?? '';
      apellido = json['apellido'] ?? '';
    }

    String? plan;
    double? precio;
    String? fechaVenc;

    if (json['membresia'] != null) {
      if (json['membresia'] is List && (json['membresia'] as List).isNotEmpty) {
        final m = (json['membresia'] as List).first;
        plan = m['tipo'];
        precio = m['precio'] != null ? double.tryParse(m['precio'].toString()) : null;
        fechaVenc = m['fecha_vencimiento'];
      } else if (json['membresia'] is Map) {
        plan = json['membresia']['tipo'];
        precio = json['membresia']['precio'] != null ? double.tryParse(json['membresia']['precio'].toString()) : null;
        fechaVenc = json['membresia']['fecha_vencimiento'];
      }
    }

    return SocioModel(
      idSocio: json['id_socio'],
      idUsuario: json['id_usuario'],
      nombre: nombre,
      apellido: apellido,
      dni: (json['dni'] ?? '').toString(),
      telefono: json['telefono']?.toString(),
      estado: json['estado'] ?? 'activo',
      plan: plan ?? json['plan'] ?? 'Plan Mensual',
      precio: precio,
      fechaVencimiento: fechaVenc ?? json['fecha_vencimiento'],
      fechaAlta: json['fecha_alta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_socio': idSocio,
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'telefono': telefono,
      'estado': estado,
      'plan': plan,
      'precio': precio,
      'fecha_vencimiento': fechaVencimiento,
      'fecha_alta': fechaAlta,
    };
  }
}

class SocioStatsModel {
  final int total;
  final int activos;
  final int pendientes;
  final int inactivos;
  final int nuevosEsteMes;

  SocioStatsModel({
    required this.total,
    required this.activos,
    required this.pendientes,
    required this.inactivos,
    required this.nuevosEsteMes,
  });

  int get pctActivos => total > 0 ? ((activos / total) * 100).round() : 0;
  int get pctPendientes => total > 0 ? ((pendientes / total) * 100).round() : 0;
  int get pctInactivos => total > 0 ? ((inactivos / total) * 100).round() : 0;

  factory SocioStatsModel.fromJson(Map<String, dynamic> json) {
    return SocioStatsModel(
      total: json['total'] ?? 0,
      activos: json['activos'] ?? 0,
      pendientes: json['pendientes'] ?? 0,
      inactivos: json['inactivos'] ?? 0,
      nuevosEsteMes: json['nuevosEsteMes'] ?? 0,
    );
  }

  factory SocioStatsModel.defaultStats() {
    return SocioStatsModel(
      total: 128,
      activos: 96,
      pendientes: 18,
      inactivos: 14,
      nuevosEsteMes: 8,
    );
  }
}
