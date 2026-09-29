import 'ejercicio_model.dart';

class RutinaEjercicioModel {
  final int? idRutinaEjercicio;
  final int idEjercicio;
  final int series;
  final int repeticiones;
  final double? peso;
  final int? descanso; // segundos
  final int? orden;
  final EjercicioModel? ejercicio;

  RutinaEjercicioModel({
    this.idRutinaEjercicio,
    required this.idEjercicio,
    required this.series,
    required this.repeticiones,
    this.peso,
    this.descanso,
    this.orden,
    this.ejercicio,
  });

  factory RutinaEjercicioModel.fromJson(Map<String, dynamic> json) {
    return RutinaEjercicioModel(
      idRutinaEjercicio: json['id_rutina_ejercicio'] is int
          ? json['id_rutina_ejercicio']
          : int.tryParse(json['id_rutina_ejercicio']?.toString() ?? ''),
      idEjercicio: json['id_ejercicio'] is int
          ? json['id_ejercicio']
          : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? 0,
      series: json['series'] is int
          ? json['series']
          : int.tryParse(json['series']?.toString() ?? '3') ?? 3,
      repeticiones: json['repeticiones'] is int
          ? json['repeticiones']
          : int.tryParse(json['repeticiones']?.toString() ?? '10') ?? 10,
      peso: json['peso'] != null ? double.tryParse(json['peso'].toString()) : null,
      descanso: json['descanso'] is int
          ? json['descanso']
          : int.tryParse(json['descanso']?.toString() ?? ''),
      orden: json['orden'] is int
          ? json['orden']
          : int.tryParse(json['orden']?.toString() ?? ''),
      ejercicio: json['ejercicio'] != null && json['ejercicio'] is Map<String, dynamic>
          ? EjercicioModel.fromJson(json['ejercicio'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ejercicio': idEjercicio,
      'series': series,
      'repeticiones': repeticiones,
      if (peso != null) 'peso': peso,
      if (descanso != null) 'descanso': descanso,
      if (orden != null) 'orden': orden,
    };
  }
}

class RutinaModel {
  final int idRutina;
  final String nombre;
  final String? descripcion;
  final String? fechaInicio;
  final String? fechaFin;
  final String estado;
  final int? idSocio;
  final String? socioNombre;
  final String? socioDni;
  final List<RutinaEjercicioModel> ejercicios;

  RutinaModel({
    required this.idRutina,
    required this.nombre,
    this.descripcion,
    this.fechaInicio,
    this.fechaFin,
    required this.estado,
    this.idSocio,
    this.socioNombre,
    this.socioDni,
    this.ejercicios = const [],
  });

  bool get isActiva => estado.toLowerCase() == 'activo' || estado.toLowerCase() == 'activa';

  factory RutinaModel.fromJson(Map<String, dynamic> json) {
    String? socioNombre;
    String? socioDni;

    if (json['socio'] != null && json['socio'] is Map<String, dynamic>) {
      final s = json['socio'];
      socioNombre = '${s['nombre'] ?? ''} ${s['apellido'] ?? ''}'.trim();
      socioDni = s['dni']?.toString();
    }

    final rawEjercicios = json['rutina_ejercicio'] as List? ?? [];
    final ejerciciosList = rawEjercicios
        .map((e) => RutinaEjercicioModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RutinaModel(
      idRutina: json['id_rutina'] is int
          ? json['id_rutina']
          : int.tryParse(json['id_rutina']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
      estado: json['estado']?.toString() ?? 'activo',
      idSocio: json['id_socio'] is int
          ? json['id_socio']
          : int.tryParse(json['id_socio']?.toString() ?? ''),
      socioNombre: socioNombre,
      socioDni: socioDni,
      ejercicios: ejerciciosList,
    );
  }
}
