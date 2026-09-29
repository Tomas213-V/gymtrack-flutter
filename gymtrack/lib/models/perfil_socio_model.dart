class PerfilSocioModel {
  final int idSocio;
  final int? idGimnasio;
  final String nombre;
  final String apellido;
  final String dni;
  final String? telefono;
  final String? email;
  final String? fechaAlta;
  final String estado;

  // Gimnasio
  final String? gimnasioNombre;
  final String? gimnasioDireccion;
  final String? gimnasioTelefono;
  final String? gimnasioEmail;

  // Membresía
  final String planNombre;
  final String? membresiaEstado;
  final String? fechaInicioMembresia;
  final String? fechaVencimiento;
  final double? precioMembresia;
  final int? diasRestantes;

  // Asistencias y Pagos
  final int totalAsistencias;
  final int totalPagos;
  final List<PerfilAsistenciaItem> ultimasAsistencias;
  final List<PerfilPagoItem> ultimosPagos;

  PerfilSocioModel({
    required this.idSocio,
    this.idGimnasio,
    required this.nombre,
    required this.apellido,
    required this.dni,
    this.telefono,
    this.email,
    this.fechaAlta,
    this.estado = 'activo',
    this.gimnasioNombre,
    this.gimnasioDireccion,
    this.gimnasioTelefono,
    this.gimnasioEmail,
    this.planNombre = 'Sin Membresía Activa',
    this.membresiaEstado,
    this.fechaInicioMembresia,
    this.fechaVencimiento,
    this.precioMembresia,
    this.diasRestantes,
    this.totalAsistencias = 0,
    this.totalPagos = 0,
    this.ultimasAsistencias = const [],
    this.ultimosPagos = const [],
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  String get iniciales {
    final n = nombre.trim();
    final a = apellido.trim();
    if (n.isNotEmpty && a.isNotEmpty) {
      return '${n[0]}${a[0]}'.toUpperCase();
    } else if (n.isNotEmpty) {
      return n.substring(0, n.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SO';
  }

  bool get isActivo => estado.toLowerCase() == 'activo';

  factory PerfilSocioModel.fromJson(Map<String, dynamic> json) {
    final socioMap = json['socio'] as Map<String, dynamic>? ?? {};
    final gymMap = json['gimnasio'] as Map<String, dynamic>?;
    final membMap = json['membresia'] as Map<String, dynamic>?;
    final statsMap = json['estadisticas'] as Map<String, dynamic>?;

    String planNombre = 'Sin Plan Asignado';
    if (membMap != null) {
      if (membMap['plan_membresia'] is Map<String, dynamic>) {
        planNombre = membMap['plan_membresia']['nombre'] ?? 'Plan General';
      } else if (membMap['nombre'] != null) {
        planNombre = membMap['nombre'];
      } else if (membMap['tipo'] != null) {
        planNombre = membMap['tipo'];
      }
    }

    final rawAsist = json['ultimasAsistencias'] as List? ?? [];
    final asistencias = rawAsist
        .map((a) => PerfilAsistenciaItem.fromJson(a as Map<String, dynamic>))
        .toList();

    final rawPagos = json['ultimosPagos'] as List? ?? [];
    final pagos = rawPagos
        .map((p) => PerfilPagoItem.fromJson(p as Map<String, dynamic>))
        .toList();

    return PerfilSocioModel(
      idSocio: socioMap['id_socio'] is int
          ? socioMap['id_socio']
          : int.tryParse(socioMap['id_socio']?.toString() ?? '0') ?? 0,
      idGimnasio: socioMap['id_gimnasio'] is int
          ? socioMap['id_gimnasio']
          : int.tryParse(socioMap['id_gimnasio']?.toString() ?? ''),
      nombre: socioMap['nombre']?.toString() ?? 'Socio',
      apellido: socioMap['apellido']?.toString() ?? '',
      dni: socioMap['dni']?.toString() ?? '',
      telefono: socioMap['telefono']?.toString(),
      email: socioMap['email']?.toString(),
      fechaAlta: socioMap['fecha_alta']?.toString(),
      estado: socioMap['estado']?.toString() ?? 'activo',
      gimnasioNombre: gymMap?['nombre']?.toString() ?? 'GymTrack Sede',
      gimnasioDireccion: gymMap?['direccion']?.toString(),
      gimnasioTelefono: gymMap?['telefono']?.toString(),
      gimnasioEmail: gymMap?['email']?.toString(),
      planNombre: planNombre,
      membresiaEstado: membMap?['estado']?.toString(),
      fechaInicioMembresia: membMap?['fecha_inicio']?.toString(),
      fechaVencimiento: membMap?['fecha_vencimiento']?.toString(),
      precioMembresia: membMap?['precio'] != null
          ? double.tryParse(membMap!['precio'].toString())
          : null,
      diasRestantes: statsMap?['diasRestantes'] as int?,
      totalAsistencias: statsMap?['totalAsistencias'] as int? ?? asistencias.length,
      totalPagos: statsMap?['totalPagos'] as int? ?? pagos.length,
      ultimasAsistencias: asistencias,
      ultimosPagos: pagos,
    );
  }
}

class PerfilAsistenciaItem {
  final int idAsistencia;
  final String horaIngreso;
  final String? horaSalida;
  final String estado;

  PerfilAsistenciaItem({
    required this.idAsistencia,
    required this.horaIngreso,
    this.horaSalida,
    required this.estado,
  });

  String get horaIngresoFormateada {
    try {
      final dt = DateTime.parse(horaIngreso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m hs';
    } catch (_) {
      return horaIngreso;
    }
  }

  String get fechaFormateada {
    try {
      final dt = DateTime.parse(horaIngreso).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      return '$d/$m/$y';
    } catch (_) {
      return '';
    }
  }

  factory PerfilAsistenciaItem.fromJson(Map<String, dynamic> json) {
    return PerfilAsistenciaItem(
      idAsistencia: json['id_asistencia'] is int
          ? json['id_asistencia']
          : int.tryParse(json['id_asistencia']?.toString() ?? '0') ?? 0,
      horaIngreso: json['hora_ingreso']?.toString() ?? '',
      horaSalida: json['hora_salida']?.toString(),
      estado: json['estado']?.toString() ?? 'presente',
    );
  }
}

class PerfilPagoItem {
  final int idPago;
  final double monto;
  final String fechaPago;
  final String metodoPago;
  final String estado;

  PerfilPagoItem({
    required this.idPago,
    required this.monto,
    required this.fechaPago,
    required this.metodoPago,
    required this.estado,
  });

  String get fechaFormateada {
    try {
      final dt = DateTime.parse(fechaPago);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      return '$d/$m/$y';
    } catch (_) {
      return fechaPago;
    }
  }

  factory PerfilPagoItem.fromJson(Map<String, dynamic> json) {
    return PerfilPagoItem(
      idPago: json['id_pago'] is int
          ? json['id_pago']
          : int.tryParse(json['id_pago']?.toString() ?? '0') ?? 0,
      monto: json['monto'] != null
          ? double.tryParse(json['monto'].toString()) ?? 0.0
          : 0.0,
      fechaPago: json['fecha_pago']?.toString() ?? '',
      metodoPago: json['metodo_pago']?.toString() ?? 'Efectivo',
      estado: json['estado']?.toString() ?? 'completado',
    );
  }
}
