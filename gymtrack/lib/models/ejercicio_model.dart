class EjercicioModel {
  final int idEjercicio;
  final String nombre;
  final String? grupoMuscular;
  final String? descripcion;
  final String? dificultad;

  EjercicioModel({
    required this.idEjercicio,
    required this.nombre,
    this.grupoMuscular,
    this.descripcion,
    this.dificultad,
  });

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    return EjercicioModel(
      idEjercicio: json['id_ejercicio'] is int
          ? json['id_ejercicio']
          : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      grupoMuscular: json['grupo_muscular']?.toString(),
      descripcion: json['descripcion']?.toString(),
      dificultad: json['dificultad']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ejercicio': idEjercicio,
      'nombre': nombre,
      if (grupoMuscular != null) 'grupo_muscular': grupoMuscular,
      if (descripcion != null) 'descripcion': descripcion,
      if (dificultad != null) 'dificultad': dificultad,
    };
  }
}
