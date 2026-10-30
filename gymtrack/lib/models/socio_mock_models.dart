// ==============================================================================
// MODELOS DE DATOS: PERFIL DE SOCIO, PROGRESO Y MEMBRESÍA (MOCKS Y DOMINIO)
// ==============================================================================

class SocioProfileModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String dni;
  final String fechaNacimiento;
  final String plan;
  final String precioPlan;
  final String estado; // 'Activa', 'Pendiente', 'Vencida'
  final String fechaInicio;
  final String fechaVencimiento;
  final int diasRestantes;
  final String ultimoPago;
  final double pesoActual;
  final double pesoInicial;
  final double cambioTotal;
  final double cambioMes;
  final int entrenamientosMes;
  final int totalEntrenamientos;

  const SocioProfileModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.fechaNacimiento,
    required this.plan,
    required this.precioPlan,
    required this.estado,
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.diasRestantes,
    required this.ultimoPago,
    required this.pesoActual,
    required this.pesoInicial,
    required this.cambioTotal,
    required this.cambioMes,
    required this.entrenamientosMes,
    required this.totalEntrenamientos,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();
  String get iniciales => '${nombre.isNotEmpty ? nombre[0] : ''}${apellido.isNotEmpty ? apellido[0] : ''}'.toUpperCase();

  SocioProfileModel copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? dni,
    String? fechaNacimiento,
    String? plan,
    String? precioPlan,
    String? estado,
    String? fechaInicio,
    String? fechaVencimiento,
    int? diasRestantes,
    String? ultimoPago,
    double? pesoActual,
    double? pesoInicial,
    double? cambioTotal,
    double? cambioMes,
    int? entrenamientosMes,
    int? totalEntrenamientos,
  }) {
    return SocioProfileModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      dni: dni ?? this.dni,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      plan: plan ?? this.plan,
      precioPlan: precioPlan ?? this.precioPlan,
      estado: estado ?? this.estado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      diasRestantes: diasRestantes ?? this.diasRestantes,
      ultimoPago: ultimoPago ?? this.ultimoPago,
      pesoActual: pesoActual ?? this.pesoActual,
      pesoInicial: pesoInicial ?? this.pesoInicial,
      cambioTotal: cambioTotal ?? this.cambioTotal,
      cambioMes: cambioMes ?? this.cambioMes,
      entrenamientosMes: entrenamientosMes ?? this.entrenamientosMes,
      totalEntrenamientos: totalEntrenamientos ?? this.totalEntrenamientos,
    );
  }

  factory SocioProfileModel.fromJson(Map<String, dynamic> json) {
    return SocioProfileModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      dni: json['dni']?.toString() ?? '',
      fechaNacimiento: json['fecha_nacimiento']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
      precioPlan: json['precio_plan']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'Activa',
      fechaInicio: json['fecha_inicio']?.toString() ?? '',
      fechaVencimiento: json['fecha_vencimiento']?.toString() ?? '',
      diasRestantes: (json['dias_restantes'] as num?)?.toInt() ?? 0,
      ultimoPago: json['ultimo_pago']?.toString() ?? '',
      pesoActual: (json['peso_actual'] as num?)?.toDouble() ?? 0.0,
      pesoInicial: (json['peso_inicial'] as num?)?.toDouble() ?? 0.0,
      cambioTotal: (json['cambio_total'] as num?)?.toDouble() ?? 0.0,
      cambioMes: (json['cambio_mes'] as num?)?.toDouble() ?? 0.0,
      entrenamientosMes: (json['entrenamientos_mes'] as num?)?.toInt() ?? 0,
      totalEntrenamientos: (json['total_entrenamientos'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'dni': dni,
      'fecha_nacimiento': fechaNacimiento,
      'plan': plan,
      'precio_plan': precioPlan,
      'estado': estado,
      'fecha_inicio': fechaInicio,
      'fecha_vencimiento': fechaVencimiento,
      'dias_restantes': diasRestantes,
      'ultimo_pago': ultimoPago,
      'peso_actual': pesoActual,
      'peso_inicial': pesoInicial,
      'cambio_total': cambioTotal,
      'cambio_mes': cambioMes,
      'entrenamientos_mes': entrenamientosMes,
      'total_entrenamientos': totalEntrenamientos,
    };
  }
}

class PagoItemModel {
  final String id;
  final String fecha;
  final String metodoPago;
  final String monto;
  final String estado; // 'Pagado', 'Pendiente'

  const PagoItemModel({
    required this.id,
    required this.fecha,
    required this.metodoPago,
    required this.monto,
    this.estado = 'Pagado',
  });

  PagoItemModel copyWith({
    String? id,
    String? fecha,
    String? metodoPago,
    String? monto,
    String? estado,
  }) {
    return PagoItemModel(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      metodoPago: metodoPago ?? this.metodoPago,
      monto: monto ?? this.monto,
      estado: estado ?? this.estado,
    );
  }

  factory PagoItemModel.fromJson(Map<String, dynamic> json) {
    return PagoItemModel(
      id: json['id']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      metodoPago: json['metodo_pago']?.toString() ?? '',
      monto: json['monto']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'Pagado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'metodo_pago': metodoPago,
      'monto': monto,
      'estado': estado,
    };
  }
}

class EjercicioModel {
  final String id;
  final String nombre;
  final String grupoMuscular; // ej: 'Pecho'
  final String categoria; // ej: 'Fuerza'
  final int series;
  final int repeticiones;
  final String peso;
  final String descanso;
  final String instrucciones;
  bool completado;

  EjercicioModel({
    required this.id,
    required this.nombre,
    required this.grupoMuscular,
    required this.categoria,
    required this.series,
    required this.repeticiones,
    required this.peso,
    required this.descanso,
    required this.instrucciones,
    this.completado = false,
  });

  String get resumenCorto => '${series}x$repeticiones  •  $peso  •  Descanso: $descanso';

  EjercicioModel copyWith({
    String? id,
    String? nombre,
    String? grupoMuscular,
    String? categoria,
    int? series,
    int? repeticiones,
    String? peso,
    String? descanso,
    String? instrucciones,
    bool? completado,
  }) {
    return EjercicioModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      categoria: categoria ?? this.categoria,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      peso: peso ?? this.peso,
      descanso: descanso ?? this.descanso,
      instrucciones: instrucciones ?? this.instrucciones,
      completado: completado ?? this.completado,
    );
  }

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    return EjercicioModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      grupoMuscular: json['grupo_muscular']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      series: (json['series'] as num?)?.toInt() ?? 0,
      repeticiones: (json['repeticiones'] as num?)?.toInt() ?? 0,
      peso: json['peso']?.toString() ?? '',
      descanso: json['descanso']?.toString() ?? '',
      instrucciones: json['instrucciones']?.toString() ?? '',
      completado: json['completado'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'grupo_muscular': grupoMuscular,
      'categoria': categoria,
      'series': series,
      'repeticiones': repeticiones,
      'peso': peso,
      'descanso': descanso,
      'instrucciones': instrucciones,
      'completado': completado,
    };
  }
}

class RutinaModel {
  final String nombre;
  final String entrenador;
  final List<String> diasSemana; // ['L', 'M', 'X', 'J', 'V']
  final List<String> diasActivos; // ['L', 'X', 'V']
  final List<EjercicioModel> ejercicios;

  RutinaModel({
    required this.nombre,
    required this.entrenador,
    required this.diasSemana,
    required this.diasActivos,
    required this.ejercicios,
  });

  factory RutinaModel.fromJson(Map<String, dynamic> json) {
    return RutinaModel(
      nombre: json['nombre']?.toString() ?? '',
      entrenador: json['entrenador']?.toString() ?? '',
      diasSemana: (json['dias_semana'] as List?)?.map((e) => e.toString()).toList() ?? [],
      diasActivos: (json['dias_activos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      ejercicios: (json['ejercicios'] as List?)
              ?.map((e) => EjercicioModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'entrenador': entrenador,
      'dias_semana': diasSemana,
      'dias_activos': diasActivos,
      'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgresoRegistroModel {
  final String id;
  final String fecha;
  final String nota;
  final double peso;
  final double? pecho;
  final double? cintura;
  final double? cadera;
  final double? brazo;

  const ProgresoRegistroModel({
    required this.id,
    required this.fecha,
    required this.nota,
    required this.peso,
    this.pecho,
    this.cintura,
    this.cadera,
    this.brazo,
  });

  ProgresoRegistroModel copyWith({
    String? id,
    String? fecha,
    String? nota,
    double? peso,
    double? pecho,
    double? cintura,
    double? cadera,
    double? brazo,
  }) {
    return ProgresoRegistroModel(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      nota: nota ?? this.nota,
      peso: peso ?? this.peso,
      pecho: pecho ?? this.pecho,
      cintura: cintura ?? this.cintura,
      cadera: cadera ?? this.cadera,
      brazo: brazo ?? this.brazo,
    );
  }

  factory ProgresoRegistroModel.fromJson(Map<String, dynamic> json) {
    return ProgresoRegistroModel(
      id: json['id']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      nota: json['nota']?.toString() ?? '',
      peso: (json['peso'] as num?)?.toDouble() ?? 0.0,
      pecho: (json['pecho'] as num?)?.toDouble(),
      cintura: (json['cintura'] as num?)?.toDouble(),
      cadera: (json['cadera'] as num?)?.toDouble(),
      brazo: (json['brazo'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'nota': nota,
      'peso': peso,
      'pecho': pecho,
      'cintura': cintura,
      'cadera': cadera,
      'brazo': brazo,
    };
  }
}

class ProgresoPuntoModel {
  final String mes;
  final double peso;

  const ProgresoPuntoModel({
    required this.mes,
    required this.peso,
  });

  factory ProgresoPuntoModel.fromJson(Map<String, dynamic> json) {
    return ProgresoPuntoModel(
      mes: json['mes']?.toString() ?? '',
      peso: (json['peso'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'peso': peso,
    };
  }
}
