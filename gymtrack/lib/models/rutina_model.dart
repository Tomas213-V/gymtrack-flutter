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
    EjercicioModel? ej;
    if (json['ejercicio'] != null && json['ejercicio'] is Map<String, dynamic>) {
      ej = EjercicioModel.fromJson(json['ejercicio']);
    } else if (json['nombre'] != null) {
      ej = EjercicioModel(
        idEjercicio: json['id_ejercicio'] is int
            ? json['id_ejercicio']
            : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? 0,
        nombre: json['nombre']?.toString() ?? '',
        grupoMuscular: json['grupo_muscular']?.toString() ?? 'General',
        dificultad: json['dificultad']?.toString() ?? 'Intermedia',
        descripcion: json['descripcion']?.toString(),
      );
    }

    return RutinaEjercicioModel(
      idRutinaEjercicio: json['id_rutina_ejercicio'] is int
          ? json['id_rutina_ejercicio']
          : int.tryParse(json['id_rutina_ejercicio']?.toString() ?? ''),
      idEjercicio: json['id_ejercicio'] is int
          ? json['id_ejercicio']
          : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? (ej?.idEjercicio ?? 0),
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
      ejercicio: ej,
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
  final bool esOfrecidaGym;
  final String? tipo;
  final String? dificultad;
  final String? dias;
  final String? duracion;
  final String? objetivo;
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
    this.esOfrecidaGym = false,
    this.tipo,
    this.dificultad,
    this.dias,
    this.duracion,
    this.objetivo,
    this.ejercicios = const [],
  });

  bool get isActiva => estado.toLowerCase() == 'activo' || estado.toLowerCase() == 'activa';
  bool get esDelGimnasio => esOfrecidaGym || (idSocio == null);
  bool get esPropia => !esDelGimnasio;

  RutinaModel copyWith({
    int? idRutina,
    String? nombre,
    String? descripcion,
    String? fechaInicio,
    String? fechaFin,
    String? estado,
    int? idSocio,
    String? socioNombre,
    String? socioDni,
    bool? esOfrecidaGym,
    String? tipo,
    String? dificultad,
    String? dias,
    String? duracion,
    String? objetivo,
    List<RutinaEjercicioModel>? ejercicios,
  }) {
    return RutinaModel(
      idRutina: idRutina ?? this.idRutina,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      idSocio: idSocio ?? this.idSocio,
      socioNombre: socioNombre ?? this.socioNombre,
      socioDni: socioDni ?? this.socioDni,
      esOfrecidaGym: esOfrecidaGym ?? this.esOfrecidaGym,
      tipo: tipo ?? this.tipo,
      dificultad: dificultad ?? this.dificultad,
      dias: dias ?? this.dias,
      duracion: duracion ?? this.duracion,
      objetivo: objetivo ?? this.objetivo,
      ejercicios: ejercicios ?? this.ejercicios,
    );
  }

  factory RutinaModel.fromJson(Map<String, dynamic> json) {
    String? socioNombre;
    String? socioDni;

    if (json['socio'] != null && json['socio'] is Map<String, dynamic>) {
      final s = json['socio'];
      socioNombre = '${s['nombre'] ?? ''} ${s['apellido'] ?? ''}'.trim();
      socioDni = s['dni']?.toString();
    }

    final rawEjercicios = (json['ejercicios'] as List?) ?? (json['rutina_ejercicio'] as List?) ?? [];
    final ejerciciosList = rawEjercicios
        .map((e) => RutinaEjercicioModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final bool esGym = json['es_ofrecida_gym'] == true ||
        (json['id_plantilla'] != null) ||
        (json['id_socio'] == null);

    int idParsed = 0;
    if (json['id_rutina'] != null) {
      idParsed = json['id_rutina'] is int
          ? json['id_rutina']
          : int.tryParse(json['id_rutina'].toString()) ?? 0;
    } else if (json['id_plantilla'] != null) {
      idParsed = json['id_plantilla'].toString().hashCode.abs();
    }

    return RutinaModel(
      idRutina: idParsed,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? json['objetivo']?.toString(),
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
      estado: json['estado']?.toString() ?? 'activo',
      idSocio: json['id_socio'] is int
          ? json['id_socio']
          : int.tryParse(json['id_socio']?.toString() ?? ''),
      socioNombre: socioNombre,
      socioDni: socioDni,
      esOfrecidaGym: esGym,
      tipo: json['tipo']?.toString(),
      dificultad: json['dificultad']?.toString() ?? json['nivel_badge']?.toString(),
      dias: json['dias']?.toString() ?? json['frecuencia']?.toString(),
      duracion: json['duracion']?.toString(),
      objetivo: json['objetivo']?.toString(),
      ejercicios: ejerciciosList,
    );
  }
}
