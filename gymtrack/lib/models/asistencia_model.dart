class AsistenciaItemModel {
  final int idAsistencia;
  final int idSocio;
  final String horaIngreso;
  final String? horaSalida;
  final String estado;
  final String socioNombre;
  final String socioApellido;
  final String socioDni;
  final String? socioEmail;
  final String? socioTelefono;

  AsistenciaItemModel({
    required this.idAsistencia,
    required this.idSocio,
    required this.horaIngreso,
    this.horaSalida,
    required this.estado,
    required this.socioNombre,
    required this.socioApellido,
    required this.socioDni,
    this.socioEmail,
    this.socioTelefono,
  });

  String get socioNombreCompleto => '$socioNombre $socioApellido'.trim();

  String get horaFormateada {
    try {
      final dt = DateTime.parse(horaIngreso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
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

  factory AsistenciaItemModel.fromJson(Map<String, dynamic> json) {
    final socioMap = json['socio'] as Map<String, dynamic>? ?? {};
    return AsistenciaItemModel(
      idAsistencia: json['id_asistencia'] is int
          ? json['id_asistencia']
          : int.tryParse(json['id_asistencia']?.toString() ?? '0') ?? 0,
      idSocio: json['id_socio'] is int
          ? json['id_socio']
          : int.tryParse(json['id_socio']?.toString() ?? '0') ?? 0,
      horaIngreso: json['hora_ingreso']?.toString() ?? '',
      horaSalida: json['hora_salida']?.toString(),
      estado: json['estado']?.toString() ?? 'presente',
      socioNombre: socioMap['nombre']?.toString() ?? '',
      socioApellido: socioMap['apellido']?.toString() ?? '',
      socioDni: socioMap['dni']?.toString() ?? '',
      socioEmail: socioMap['email']?.toString(),
      socioTelefono: socioMap['telefono']?.toString(),
    );
  }
}

class AsistenciaEstadisticasModel {
  final int totalMesActual;
  final int totalMesAnterior;
  final int porcentajeCambio;
  final String tendencia;
  final int presentesHoy;
  final int ingresosHoy;

  AsistenciaEstadisticasModel({
    required this.totalMesActual,
    required this.totalMesAnterior,
    required this.porcentajeCambio,
    required this.tendencia,
    this.presentesHoy = 0,
    this.ingresosHoy = 0,
  });

  factory AsistenciaEstadisticasModel.fromJson(Map<String, dynamic> json) {
    return AsistenciaEstadisticasModel(
      totalMesActual: json['totalMesActual'] as int? ?? 0,
      totalMesAnterior: json['totalMesAnterior'] as int? ?? 0,
      porcentajeCambio: json['porcentajeCambio'] as int? ?? 0,
      tendencia: json['tendencia']?.toString() ?? 'neutral',
      presentesHoy: json['presentesHoy'] as int? ?? 0,
      ingresosHoy: json['ingresosHoy'] as int? ?? 0,
    );
  }
}
