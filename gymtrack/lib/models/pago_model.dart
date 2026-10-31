class PagoModel {
  final dynamic idPago;
  final String socioNombre;
  final String plan;
  final String fechaPago;
  final double monto;
  final String estado; // 'pagado', 'pendiente', 'vencido'
  final String? metodoPago;
  final String? comprobante;
  final String? dniSocio;
  final String? telefonoSocio;
  final String? emailSocio;
  final String? fechaVencimiento;

  PagoModel({
    required this.idPago,
    required this.socioNombre,
    required this.plan,
    required this.fechaPago,
    required this.monto,
    required this.estado,
    this.metodoPago,
    this.comprobante,
    this.dniSocio,
    this.telefonoSocio,
    this.emailSocio,
    this.fechaVencimiento,
  });

  PagoModel copyWith({
    dynamic idPago,
    String? socioNombre,
    String? plan,
    String? fechaPago,
    double? monto,
    String? estado,
    String? metodoPago,
    String? comprobante,
    String? dniSocio,
    String? telefonoSocio,
    String? emailSocio,
    String? fechaVencimiento,
  }) {
    return PagoModel(
      idPago: idPago ?? this.idPago,
      socioNombre: socioNombre ?? this.socioNombre,
      plan: plan ?? this.plan,
      fechaPago: fechaPago ?? this.fechaPago,
      monto: monto ?? this.monto,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
      comprobante: comprobante ?? this.comprobante,
      dniSocio: dniSocio ?? this.dniSocio,
      telefonoSocio: telefonoSocio ?? this.telefonoSocio,
      emailSocio: emailSocio ?? this.emailSocio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
    );
  }

  bool get isPagado => estado.toLowerCase() == 'pagado';
  bool get isPendiente => estado.toLowerCase() == 'pendiente';
  bool get isVencido => estado.toLowerCase() == 'vencido';

  String get formattedMonto {
    final intValue = monto.toInt();
    // Formato con punto de miles ej: $18.000
    final parts = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '\$$parts';
  }

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    String nombre = 'Socio';
    String plan = 'Plan General';

    String? comprobante = json['comprobante']?.toString();
    String? dni;
    String? telefono;
    String? email;
    String? fechaVenc;

    // 1. Extraer desde la relación de membresía
    if (json['membresia'] != null && json['membresia'] is Map<String, dynamic>) {
      final memb = json['membresia'] as Map<String, dynamic>;
      fechaVenc = memb['fecha_vencimiento']?.toString();

      // Plan de membresía
      if (memb['plan_membresia'] != null && memb['plan_membresia'] is Map<String, dynamic>) {
        final p = memb['plan_membresia'] as Map<String, dynamic>;
        plan = p['nombre']?.toString() ?? 'Plan General';
      } else if (memb['tipo'] != null && memb['tipo'].toString().trim().isNotEmpty) {
        plan = memb['tipo'].toString().trim();
      } else if (memb['nombre'] != null && memb['nombre'].toString().trim().isNotEmpty) {
        plan = memb['nombre'].toString().trim();
      }

      // Socio anidado dentro de membresía
      final socio = memb['socio'];
      if (socio != null && socio is Map<String, dynamic>) {
        final nom = socio['nombre']?.toString() ?? '';
        final ape = socio['apellido']?.toString() ?? '';
        final nomCompleto = '$nom $ape'.trim();
        dni = socio['dni']?.toString();
        telefono = socio['telefono']?.toString();
        email = socio['email']?.toString();

        if (nomCompleto.isNotEmpty) {
          nombre = nomCompleto;
        } else if (socio['usuario'] != null && socio['usuario'] is Map<String, dynamic>) {
          final u = socio['usuario'] as Map<String, dynamic>;
          nombre = '${u['nombre'] ?? ''} ${u['apellido'] ?? ''}'.trim();
        }
      }
    }

    // 2. Extraer si socio viene directamente anidado en el objeto pago
    if (json['socio'] != null && json['socio'] is Map<String, dynamic>) {
      final s = json['socio'] as Map<String, dynamic>;
      final nomCompleto = '${s['nombre'] ?? ''} ${s['apellido'] ?? ''}'.trim();
      if (nomCompleto.isNotEmpty) nombre = nomCompleto;
      dni ??= s['dni']?.toString();
      telefono ??= s['telefono']?.toString();
      email ??= s['email']?.toString();
    }

    // 3. Atributos directos en el objeto
    if (json['socio_nombre'] != null && json['socio_nombre'].toString().trim().isNotEmpty) {
      nombre = json['socio_nombre'].toString().trim();
    } else if (json['nombre_socio'] != null && json['nombre_socio'].toString().trim().isNotEmpty) {
      nombre = json['nombre_socio'].toString().trim();
    }

    if (json['plan'] != null && json['plan'].toString().trim().isNotEmpty) {
      plan = json['plan'].toString().trim();
    } else if (json['plan_nombre'] != null && json['plan_nombre'].toString().trim().isNotEmpty) {
      plan = json['plan_nombre'].toString().trim();
    }

    dni ??= json['dni']?.toString() ?? json['dniSocio']?.toString();
    fechaVenc ??= json['fecha_vencimiento']?.toString();
    comprobante ??= 'COMP-${json['id_pago'] ?? DateTime.now().millisecondsSinceEpoch}';

    return PagoModel(
      idPago: json['id_pago'] ?? json['id'],
      socioNombre: nombre.isNotEmpty ? nombre : 'Socio Desconocido',
      plan: plan,
      fechaPago: json['fecha_pago'] ?? json['fecha'] ?? '',
      monto: json['monto'] != null ? double.tryParse(json['monto'].toString()) ?? 0.0 : 0.0,
      estado: (json['estado'] ?? 'pagado').toString().toLowerCase(),
      metodoPago: json['metodo_pago'] ?? json['metodoPago'] ?? 'Efectivo',
      comprobante: comprobante,
      dniSocio: dni,
      telefonoSocio: telefono,
      emailSocio: email,
      fechaVencimiento: fechaVenc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pago': idPago,
      'socio_nombre': socioNombre,
      'plan': plan,
      'fecha_pago': fechaPago,
      'monto': monto,
      'estado': estado,
      'metodo_pago': metodoPago,
      'comprobante': comprobante,
      'dni': dniSocio,
      'telefono': telefonoSocio,
      'email': emailSocio,
      'fecha_vencimiento': fechaVencimiento,
    };
  }
}

class ResumenPagosModel {
  final double totalRecaudado;
  final int pagosRealizados;
  final int pagosPendientes;
  final int pagosVencidos;

  ResumenPagosModel({
    required this.totalRecaudado,
    required this.pagosRealizados,
    required this.pagosPendientes,
    this.pagosVencidos = 0,
  });

  String get formattedTotalRecaudado {
    final intValue = totalRecaudado.toInt();
    final parts = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '\$$parts';
  }

  factory ResumenPagosModel.fromJson(Map<String, dynamic> json) {
    return ResumenPagosModel(
      totalRecaudado: json['total_recaudado'] != null
          ? double.tryParse(json['total_recaudado'].toString()) ?? 0.0
          : 0.0,
      pagosRealizados: json['pagos_realizados'] ?? 0,
      pagosPendientes: json['pagos_pendientes'] ?? 0,
      pagosVencidos: json['pagos_vencidos'] ?? 0,
    );
  }

  factory ResumenPagosModel.defaultResumen() {
    return ResumenPagosModel(
      totalRecaudado: 156000,
      pagosRealizados: 12,
      pagosPendientes: 3,
      pagosVencidos: 1,
    );
  }
}
