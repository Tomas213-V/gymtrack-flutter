class PagoModel {
  final dynamic idPago;
  final String socioNombre;
  final String plan;
  final String fechaPago;
  final double monto;
  final String estado; // 'pagado', 'pendiente', 'vencido'
  final String? metodoPago;

  PagoModel({
    required this.idPago,
    required this.socioNombre,
    required this.plan,
    required this.fechaPago,
    required this.monto,
    required this.estado,
    this.metodoPago,
  });

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

    if (json['membresia'] != null && json['membresia'] is Map<String, dynamic>) {
      plan = json['membresia']['tipo'] ?? 'Plan General';
      final socio = json['membresia']['socio'];
      if (socio != null && socio is Map<String, dynamic>) {
        final usuario = socio['usuario'];
        if (usuario != null && usuario is Map<String, dynamic>) {
          nombre = '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}'.trim();
        }
      }
    }

    if (json['socio_nombre'] != null) {
      nombre = json['socio_nombre'];
    }
    if (json['plan'] != null) {
      plan = json['plan'];
    }

    return PagoModel(
      idPago: json['id_pago'] ?? json['id'],
      socioNombre: nombre.isNotEmpty ? nombre : 'Socio Desconocido',
      plan: plan,
      fechaPago: json['fecha_pago'] ?? json['fecha'] ?? '',
      monto: json['monto'] != null ? double.tryParse(json['monto'].toString()) ?? 0.0 : 0.0,
      estado: (json['estado'] ?? 'pagado').toString().toLowerCase(),
      metodoPago: json['metodo_pago'],
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
