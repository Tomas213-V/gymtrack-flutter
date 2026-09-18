class VideoModel {
  final String id;
  String titulo;
  String descripcion;
  String categoria; // Pecho, Espalda, Piernas, Brazos, Hombros, Cardio, General
  String duracion; // ej: "08:32"
  String url;
  String thumbnailUrl;
  String estado; // 'Publicado', 'Borrador'
  String infoEjercicio;

  VideoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.duracion,
    this.url = 'https://gymtrack.app/videos/sample',
    this.thumbnailUrl = '',
    this.estado = 'Publicado',
    this.infoEjercicio = '',
  });

  VideoModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? duracion,
    String? url,
    String? thumbnailUrl,
    String? estado,
    String? infoEjercicio,
  }) {
    return VideoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      duracion: duracion ?? this.duracion,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      estado: estado ?? this.estado,
      infoEjercicio: infoEjercicio ?? this.infoEjercicio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'duracion': duracion,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'estado': estado,
      'info_ejercicio': infoEjercicio,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? 'General',
      duracion: json['duracion'] ?? '05:00',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      estado: json['estado'] ?? 'Publicado',
      infoEjercicio: json['info_ejercicio'] ?? '',
    );
  }
}
