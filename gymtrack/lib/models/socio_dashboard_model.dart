// ==============================================================================
// MODELOS PARA EL PORTAL DEL SOCIO (DASHBOARD, MEMBRESÍA Y PLANES)
// ==============================================================================

class SocioInfoModel {
  final int idSocio;
  final String nombre;
  final String apellido;
  final String dni;
  final String email;
  final String telefono;

  SocioInfoModel({
    required this.idSocio,
    required this.nombre,
    required this.apellido,
    required this.dni,
    this.email = '',
    this.telefono = '',
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory SocioInfoModel.fromJson(Map<String, dynamic> json) {
    return SocioInfoModel(
      idSocio: json['id_socio'] is int ? json['id_socio'] : int.tryParse(json['id_socio']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      dni: json['dni']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
    );
  }
}

class GimnasioInfoModel {
  final int? idGimnasio;
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;

  GimnasioInfoModel({
    this.idGimnasio,
    required this.nombre,
    this.direccion = '',
    this.telefono = '',
    this.email = '',
  });

  factory GimnasioInfoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return GimnasioInfoModel(nombre: 'GymTrack Fitness');
    }
    return GimnasioInfoModel(
      idGimnasio: json['id_gimnasio'] is int ? json['id_gimnasio'] : int.tryParse(json['id_gimnasio']?.toString() ?? ''),
      nombre: json['nombre']?.toString() ?? 'GymTrack Fitness',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class MembresiaDashboardModel {
  final int? idMembresia;
  final int? idPlanMembresia;
  final String plan;
  final String descripcionPlan;
  final String estado;
  final String? fechaInicio;
  final String? fechaVencimiento;
  final double precio;
  final int diasRestantes;
  final int porcentajeTranscurrido;
  final bool expirada;

  MembresiaDashboardModel({
    this.idMembresia,
    this.idPlanMembresia,
    required this.plan,
    this.descripcionPlan = '',
    required this.estado,
    this.fechaInicio,
    this.fechaVencimiento,
    this.precio = 0.0,
    this.diasRestantes = 0,
    this.porcentajeTranscurrido = 0,
    this.expirada = false,
  });

  bool get isActiva => !expirada && (estado.toLowerCase() == 'activo' || estado.toLowerCase() == 'activa');

  String get precioFormateado => '\$${precio.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  factory MembresiaDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MembresiaDashboardModel(
        plan: 'Sin Membresía Activa',
        estado: 'sin_membresia',
        expirada: true,
      );
    }

    final precioRaw = json['precio'];
    double precioNum = 0.0;
    if (precioRaw != null) {
      precioNum = double.tryParse(precioRaw.toString()) ?? 0.0;
    }

    return MembresiaDashboardModel(
      idMembresia: json['id_membresia'] is int ? json['id_membresia'] : int.tryParse(json['id_membresia']?.toString() ?? ''),
      idPlanMembresia: json['id_plan_membresia'] is int ? json['id_plan_membresia'] : int.tryParse(json['id_plan_membresia']?.toString() ?? ''),
      plan: json['plan']?.toString() ?? json['nombre_plan']?.toString() ?? 'Plan General',
      descripcionPlan: json['descripcion_plan']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'activo',
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaVencimiento: json['fecha_vencimiento']?.toString(),
      precio: precioNum,
      diasRestantes: json['dias_restantes'] is int ? json['dias_restantes'] : int.tryParse(json['dias_restantes']?.toString() ?? '0') ?? 0,
      porcentajeTranscurrido: json['porcentaje_transcurrido'] is int ? json['porcentaje_transcurrido'] : int.tryParse(json['porcentaje_transcurrido']?.toString() ?? '0') ?? 0,
      expirada: json['expirada'] == true || (json['esta_vencida'] == true),
    );
  }
}

class PagoRecienteModel {
  final int? idPago;
  final double monto;
  final String? fechaPago;
  final String metodoPago;
  final String estado;
  final String? comprobante;

  PagoRecienteModel({
    this.idPago,
    required this.monto,
    this.fechaPago,
    this.metodoPago = 'efectivo',
    this.estado = 'pagado',
    this.comprobante,
  });

  String get montoFormateado => '\$${monto.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  factory PagoRecienteModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PagoRecienteModel(monto: 0.0);
    }
    final montoRaw = json['monto'];
    double montoNum = 0.0;
    if (montoRaw != null) {
      montoNum = double.tryParse(montoRaw.toString()) ?? 0.0;
    }

    return PagoRecienteModel(
      idPago: json['id_pago'] is int ? json['id_pago'] : int.tryParse(json['id_pago']?.toString() ?? ''),
      monto: montoNum,
      fechaPago: json['fecha_pago']?.toString(),
      metodoPago: json['metodo_pago']?.toString() ?? 'efectivo',
      estado: json['estado']?.toString() ?? 'pagado',
      comprobante: json['comprobante']?.toString(),
    );
  }
}

class ProgresoRegistroModel {
  final int? idProgreso;
  final double peso;
  final String fecha;
  final String? observaciones;

  ProgresoRegistroModel({
    this.idProgreso,
    required this.peso,
    required this.fecha,
    this.observaciones,
  });

  factory ProgresoRegistroModel.fromJson(Map<String, dynamic> json) {
    final pesoRaw = json['peso'];
    double pesoNum = 0.0;
    if (pesoRaw != null) {
      pesoNum = double.tryParse(pesoRaw.toString()) ?? 0.0;
    }
    return ProgresoRegistroModel(
      idProgreso: json['id_progreso'] is int ? json['id_progreso'] : int.tryParse(json['id_progreso']?.toString() ?? ''),
      peso: pesoNum,
      fecha: json['fecha']?.toString() ?? '',
      observaciones: json['observaciones']?.toString(),
    );
  }
}

class ProgresoDashboardModel {
  final double? pesoActual;
  final String? observaciones;
  final String? fechaUltimoRegistro;
  final double? variacionMes;
  final List<ProgresoRegistroModel> historial;

  ProgresoDashboardModel({
    this.pesoActual,
    this.observaciones,
    this.fechaUltimoRegistro,
    this.variacionMes,
    this.historial = const [],
  });

  factory ProgresoDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProgresoDashboardModel();

    final pesoRaw = json['peso_actual'];
    double? pesoNum;
    if (pesoRaw != null) pesoNum = double.tryParse(pesoRaw.toString());

    final varRaw = json['variacion_mes'];
    double? varNum;
    if (varRaw != null) varNum = double.tryParse(varRaw.toString());

    final histRaw = json['historial'] as List? ?? [];
    final hist = histRaw
        .map((e) => ProgresoRegistroModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProgresoDashboardModel(
      pesoActual: pesoNum,
      observaciones: json['observaciones']?.toString(),
      fechaUltimoRegistro: json['fecha_ultimo_registro']?.toString(),
      variacionMes: varNum,
      historial: hist,
    );
  }
}

class EntrenamientosDashboardModel {
  final int totalAsistencias;
  final int asistenciasMes;
  final List<dynamic> recientes;

  EntrenamientosDashboardModel({
    this.totalAsistencias = 0,
    this.asistenciasMes = 0,
    this.recientes = const [],
  });

  factory EntrenamientosDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EntrenamientosDashboardModel();
    return EntrenamientosDashboardModel(
      totalAsistencias: json['total_asistencias'] is int ? json['total_asistencias'] : int.tryParse(json['total_asistencias']?.toString() ?? '0') ?? 0,
      asistenciasMes: json['asistencias_mes'] is int ? json['asistencias_mes'] : int.tryParse(json['asistencias_mes']?.toString() ?? '0') ?? 0,
      recientes: json['recientes'] as List? ?? [],
    );
  }
}

class SocioDashboardModel {
  final SocioInfoModel socio;
  final GimnasioInfoModel gimnasio;
  final MembresiaDashboardModel membresia;
  final PagoRecienteModel? ultimoPago;
  final ProgresoDashboardModel progreso;
  final EntrenamientosDashboardModel entrenamientos;
  final Map<String, dynamic>? rutinaActiva;

  SocioDashboardModel({
    required this.socio,
    required this.gimnasio,
    required this.membresia,
    this.ultimoPago,
    required this.progreso,
    required this.entrenamientos,
    this.rutinaActiva,
  });

  factory SocioDashboardModel.fromJson(Map<String, dynamic> json) {
    return SocioDashboardModel(
      socio: SocioInfoModel.fromJson(json['socio'] as Map<String, dynamic>? ?? {}),
      gimnasio: GimnasioInfoModel.fromJson(json['gimnasio'] as Map<String, dynamic>?),
      membresia: MembresiaDashboardModel.fromJson(json['membresia'] as Map<String, dynamic>?),
      ultimoPago: json['ultimo_pago'] != null ? PagoRecienteModel.fromJson(json['ultimo_pago'] as Map<String, dynamic>?) : null,
      progreso: ProgresoDashboardModel.fromJson(json['progreso'] as Map<String, dynamic>?),
      entrenamientos: EntrenamientosDashboardModel.fromJson(json['entrenamientos'] as Map<String, dynamic>?),
      rutinaActiva: json['rutina_activa'] as Map<String, dynamic>?,
    );
  }
}

class PlanDisponibleModel {
  final int idPlanMembresia;
  final int? idGimnasio;
  final String nombre;
  final double precio;
  final String precioFormateado;
  final int duracionDias;
  final String duracionTexto;
  final bool esPlanActual;
  final bool esSuperior;
  final double diferenciaPrecio;
  final String? diferenciaPrecioFormateada;
  final List<String> beneficios;

  PlanDisponibleModel({
    required this.idPlanMembresia,
    this.idGimnasio,
    required this.nombre,
    required this.precio,
    required this.precioFormateado,
    required this.duracionDias,
    required this.duracionTexto,
    this.esPlanActual = false,
    this.esSuperior = false,
    this.diferenciaPrecio = 0.0,
    this.diferenciaPrecioFormateada,
    this.beneficios = const [],
  });

  factory PlanDisponibleModel.fromJson(Map<String, dynamic> json) {
    final precioRaw = json['precio'];
    double precioNum = 0.0;
    if (precioRaw != null) {
      precioNum = double.tryParse(precioRaw.toString()) ?? 0.0;
    }

    final difRaw = json['diferencia_precio'];
    double difNum = 0.0;
    if (difRaw != null) {
      difNum = double.tryParse(difRaw.toString()) ?? 0.0;
    }

    final rawBen = json['beneficios'] as List? ?? [];
    final ben = rawBen.map((e) => e.toString()).toList();

    return PlanDisponibleModel(
      idPlanMembresia: json['id_plan_membresia'] is int ? json['id_plan_membresia'] : int.tryParse(json['id_plan_membresia']?.toString() ?? '0') ?? 0,
      idGimnasio: json['id_gimnasio'] is int ? json['id_gimnasio'] : int.tryParse(json['id_gimnasio']?.toString() ?? ''),
      nombre: json['nombre']?.toString() ?? 'Plan',
      precio: precioNum,
      precioFormateado: json['precio_formateado']?.toString() ?? '\$${precioNum.toStringAsFixed(0)}',
      duracionDias: json['duracion_dias'] is int ? json['duracion_dias'] : int.tryParse(json['duracion_dias']?.toString() ?? '30') ?? 30,
      duracionTexto: json['duracion_texto']?.toString() ?? '${json['duracion_dias'] ?? 30} días',
      esPlanActual: json['es_plan_actual'] == true,
      esSuperior: json['es_superior'] == true,
      diferenciaPrecio: difNum,
      diferenciaPrecioFormateada: json['diferencia_precio_formateada']?.toString(),
      beneficios: ben,
    );
  }
}
