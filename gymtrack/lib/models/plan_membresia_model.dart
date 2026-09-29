class PlanMembresiaModel {
  final int idPlanMembresia;
  final int idGimnasio;
  final String nombre;
  final double precio;
  final int duracionDias;
  final String estado;

  PlanMembresiaModel({
    required this.idPlanMembresia,
    required this.idGimnasio,
    required this.nombre,
    required this.precio,
    required this.duracionDias,
    required this.estado,
  });

  bool get isActivo => estado.toLowerCase() == 'activo';

  String get duracionTexto {
    if (duracionDias == 30) return '1 Mes';
    if (duracionDias == 60) return '2 Meses';
    if (duracionDias == 90) return '3 Meses';
    if (duracionDias == 180) return '6 Meses';
    if (duracionDias == 365) return '1 Año';
    return '$duracionDias días';
  }

  factory PlanMembresiaModel.fromJson(Map<String, dynamic> json) {
    return PlanMembresiaModel(
      idPlanMembresia: json['id_plan_membresia'] is int
          ? json['id_plan_membresia']
          : int.tryParse(json['id_plan_membresia']?.toString() ?? '0') ?? 0,
      idGimnasio: json['id_gimnasio'] is int
          ? json['id_gimnasio']
          : int.tryParse(json['id_gimnasio']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      precio: json['precio'] != null
          ? double.tryParse(json['precio'].toString()) ?? 0.0
          : 0.0,
      duracionDias: json['duracion_dias'] is int
          ? json['duracion_dias']
          : int.tryParse(json['duracion_dias']?.toString() ?? '30') ?? 30,
      estado: json['estado']?.toString() ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_plan_membresia': idPlanMembresia,
      'id_gimnasio': idGimnasio,
      'nombre': nombre,
      'precio': precio,
      'duracion_dias': duracionDias,
      'estado': estado,
    };
  }
}
