class EjercicioModel {
  final int idEjercicio;
  final String nombre;
  final String? grupoMuscular;
  final String? descripcion;
  final String? dificultad;
  final int? idSocio;
  final int? idGimnasio;
  final String? origen;
  final bool esPropio;
  final bool esGimnasio;
  final bool puedeEditar;
  final bool puedeEliminar;

  EjercicioModel({
    required this.idEjercicio,
    required this.nombre,
    this.grupoMuscular,
    this.descripcion,
    this.dificultad,
    this.idSocio,
    this.idGimnasio,
    this.origen,
    this.esPropio = false,
    this.esGimnasio = true,
    this.puedeEditar = false,
    this.puedeEliminar = false,
  });

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    final rawSocioId = json['id_socio'];
    final parsedSocioId = rawSocioId is int
        ? rawSocioId
        : int.tryParse(rawSocioId?.toString() ?? '');

    final rawGymId = json['id_gimnasio'];
    final parsedGymId = rawGymId is int
        ? rawGymId
        : int.tryParse(rawGymId?.toString() ?? '');

    final bool isPropio = json['es_propio'] == true ||
        json['tipo_origen'] == 'propio' ||
        parsedSocioId != null;

    final bool isGym = json['es_gimnasio'] == true ||
        json['tipo_origen'] == 'gimnasio' ||
        parsedSocioId == null;

    final bool canEdit = json['puede_editar'] == true || isPropio;
    final bool canDelete = json['puede_eliminar'] == true || isPropio;

    return EjercicioModel(
      idEjercicio: json['id_ejercicio'] is int
          ? json['id_ejercicio']
          : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      grupoMuscular: json['grupo_muscular']?.toString(),
      descripcion: json['descripcion']?.toString(),
      dificultad: json['dificultad']?.toString(),
      idSocio: parsedSocioId,
      idGimnasio: parsedGymId,
      origen: json['origen']?.toString() ?? (isPropio ? 'Mi ejercicio' : 'Gimnasio'),
      esPropio: isPropio,
      esGimnasio: isGym,
      puedeEditar: canEdit,
      puedeEliminar: canDelete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ejercicio': idEjercicio,
      'nombre': nombre,
      if (grupoMuscular != null) 'grupo_muscular': grupoMuscular,
      if (descripcion != null) 'descripcion': descripcion,
      if (dificultad != null) 'dificultad': dificultad,
      if (idSocio != null) 'id_socio': idSocio,
      if (idGimnasio != null) 'id_gimnasio': idGimnasio,
      if (origen != null) 'origen': origen,
      'es_propio': esPropio,
      'es_gimnasio': esGimnasio,
    };
  }
}
