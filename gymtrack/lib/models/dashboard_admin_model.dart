class DashboardAdminModel {
  final int totalSocios;
  final int sociosActivos;
  final int sociosInactivos;
  final int sociosPendientes;
  final int sociosNuevosMes;

  final double recaudacionMesActual;
  final double recaudacionMesAnterior;
  final int variacionIngresos;
  final int pagosRealizados;
  final int pagosPendientes;
  final int pagosVencidos;

  final int asistenciasHoy;
  final int asistenciasMesActual;
  final int variacionAsistencias;

  final int membresiasPorVencer;
  final int membresiasVencidas;

  final List<DashboardActividadAsistencia> ultimasAsistencias;
  final List<DashboardActividadPago> ultimosPagos;
  final List<DashboardVencimiento> proximosVencimientos;

  const DashboardAdminModel({
    required this.totalSocios,
    required this.sociosActivos,
    required this.sociosInactivos,
    required this.sociosPendientes,
    required this.sociosNuevosMes,
    required this.recaudacionMesActual,
    required this.recaudacionMesAnterior,
    required this.variacionIngresos,
    required this.pagosRealizados,
    required this.pagosPendientes,
    required this.pagosVencidos,
    required this.asistenciasHoy,
    required this.asistenciasMesActual,
    required this.variacionAsistencias,
    required this.membresiasPorVencer,
    required this.membresiasVencidas,
    this.ultimasAsistencias = const [],
    this.ultimosPagos = const [],
    this.proximosVencimientos = const [],
  });

  factory DashboardAdminModel.fromJson(Map<String, dynamic> json) {
    final kpis = (json['kpis'] as Map<String, dynamic>?) ?? {};
    final socios = (kpis['socios'] as Map<String, dynamic>?) ?? {};
    final ingresos = (kpis['ingresos'] as Map<String, dynamic>?) ?? {};
    final asistencias = (kpis['asistencias'] as Map<String, dynamic>?) ?? {};
    final actividad = (json['actividadReciente'] as Map<String, dynamic>?) ?? {};

    final rawAsist = actividad['asistencias'] as List? ?? [];
    final rawPagos = actividad['pagos'] as List? ?? [];
    final rawVenc = json['proximosVencimientos'] as List? ?? [];

    return DashboardAdminModel(
      totalSocios: (socios['total'] as num?)?.toInt() ?? 0,
      sociosActivos: (socios['activos'] as num?)?.toInt() ?? 0,
      sociosInactivos: (socios['inactivos'] as num?)?.toInt() ?? 0,
      sociosPendientes: (socios['pendientes'] as num?)?.toInt() ?? 0,
      sociosNuevosMes: (socios['nuevosMes'] as num?)?.toInt() ?? 0,

      recaudacionMesActual: (ingresos['mesActual'] as num?)?.toDouble() ?? 0.0,
      recaudacionMesAnterior: (ingresos['mesAnterior'] as num?)?.toDouble() ?? 0.0,
      variacionIngresos: (ingresos['variacionPorcentaje'] as num?)?.toInt() ?? 0,
      pagosRealizados: (ingresos['pagosRealizados'] as num?)?.toInt() ?? 0,
      pagosPendientes: (ingresos['pagosPendientes'] as num?)?.toInt() ?? 0,
      pagosVencidos: (ingresos['pagosVencidos'] as num?)?.toInt() ?? 0,

      asistenciasHoy: (asistencias['hoy'] as num?)?.toInt() ?? 0,
      asistenciasMesActual: (asistencias['mesActual'] as num?)?.toInt() ?? 0,
      variacionAsistencias: (asistencias['variacionPorcentaje'] as num?)?.toInt() ?? 0,

      membresiasPorVencer: (kpis['membresiasPorVencer'] as num?)?.toInt() ?? 0,
      membresiasVencidas: (kpis['membresiasVencidas'] as num?)?.toInt() ?? 0,

      ultimasAsistencias: rawAsist
          .map((e) => DashboardActividadAsistencia.fromJson(e as Map<String, dynamic>))
          .toList(),
      ultimosPagos: rawPagos
          .map((e) => DashboardActividadPago.fromJson(e as Map<String, dynamic>))
          .toList(),
      proximosVencimientos: rawVenc
          .map((e) => DashboardVencimiento.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DashboardAdminModel.defaultMock() {
    return const DashboardAdminModel(
      totalSocios: 128,
      sociosActivos: 115,
      sociosInactivos: 8,
      sociosPendientes: 5,
      sociosNuevosMes: 5,
      recaudacionMesActual: 82450,
      recaudacionMesAnterior: 73600,
      variacionIngresos: 12,
      pagosRealizados: 42,
      pagosPendientes: 3,
      pagosVencidos: 1,
      asistenciasHoy: 28,
      asistenciasMesActual: 380,
      variacionAsistencias: 8,
      membresiasPorVencer: 18,
      membresiasVencidas: 3,
    );
  }
}

class DashboardActividadAsistencia {
  final int? id;
  final String socio;
  final String dni;
  final String? hora;
  final String estado;

  const DashboardActividadAsistencia({
    this.id,
    required this.socio,
    required this.dni,
    this.hora,
    this.estado = 'presente',
  });

  factory DashboardActividadAsistencia.fromJson(Map<String, dynamic> json) {
    return DashboardActividadAsistencia(
      id: (json['id'] as num?)?.toInt(),
      socio: json['socio']?.toString() ?? 'Socio',
      dni: json['dni']?.toString() ?? 'S/D',
      hora: json['hora']?.toString(),
      estado: json['estado']?.toString() ?? 'presente',
    );
  }
}

class DashboardActividadPago {
  final int? id;
  final String socio;
  final String plan;
  final double monto;
  final String metodo;
  final String estado;
  final String? fecha;

  const DashboardActividadPago({
    this.id,
    required this.socio,
    required this.plan,
    required this.monto,
    required this.metodo,
    this.estado = 'pagado',
    this.fecha,
  });

  factory DashboardActividadPago.fromJson(Map<String, dynamic> json) {
    return DashboardActividadPago(
      id: (json['id'] as num?)?.toInt(),
      socio: json['socio']?.toString() ?? 'Socio',
      plan: json['plan']?.toString() ?? 'Cuota Mensual',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      metodo: json['metodo']?.toString() ?? 'Efectivo',
      estado: json['estado']?.toString() ?? 'pagado',
      fecha: json['fecha']?.toString(),
    );
  }
}

class DashboardVencimiento {
  final int? idMembresia;
  final String socioNombre;
  final String? dni;
  final String plan;
  final String? fechaVencimiento;

  const DashboardVencimiento({
    this.idMembresia,
    required this.socioNombre,
    this.dni,
    required this.plan,
    this.fechaVencimiento,
  });

  factory DashboardVencimiento.fromJson(Map<String, dynamic> json) {
    final socioMap = json['socio'] as Map<String, dynamic>?;
    return DashboardVencimiento(
      idMembresia: (json['id_membresia'] as num?)?.toInt(),
      socioNombre: socioMap?['nombre']?.toString() ?? json['socio']?.toString() ?? 'Socio',
      dni: socioMap?['dni']?.toString(),
      plan: json['plan']?.toString() ?? 'Estándar',
      fechaVencimiento: (json['fecha_fin'] ?? json['fecha_vencimiento'])?.toString(),
    );
  }
}
