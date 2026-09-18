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
  final String estado; // 'Activa', etc.
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

  SocioProfileModel({
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
}

class PagoItemModel {
  final String id;
  final String fecha;
  final String metodoPago;
  final String monto;
  final String estado; // 'Pagado', 'Pendiente'

  PagoItemModel({
    required this.id,
    required this.fecha,
    required this.metodoPago,
    required this.monto,
    this.estado = 'Pagado',
  });
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

  ProgresoRegistroModel({
    required this.id,
    required this.fecha,
    required this.nota,
    required this.peso,
    this.pecho,
    this.cintura,
    this.cadera,
    this.brazo,
  });
}

class ProgresoPuntoModel {
  final String mes;
  final double peso;

  ProgresoPuntoModel({
    required this.mes,
    required this.peso,
  });
}
