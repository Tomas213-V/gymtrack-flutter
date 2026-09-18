import '../models/video_model.dart';

class VideoMockData {
  static final VideoMockData _instance = VideoMockData._internal();
  factory VideoMockData() => _instance;
  VideoMockData._internal();

  final List<VideoModel> _videos = [
    VideoModel(
      id: 'vid-01',
      titulo: 'Técnica de Press de Banca',
      categoria: 'Pecho',
      duracion: '08:32',
      descripcion:
          'Aprende la postura correcta en el banco, cómo retraer las escápulas, el ancho óptimo de agarre y la trayectoria de la barra para proteger los hombros y maximizar la hipertrofia pectoral.',
      infoEjercicio:
          'Músculos: Pectoral mayor, deltoides anterior, tríceps. Nivel: Intermedio.',
      estado: 'Publicado',
    ),
    VideoModel(
      id: 'vid-02',
      titulo: 'Cómo realizar una Sentadilla correctamente',
      categoria: 'Piernas',
      duracion: '06:45',
      descripcion:
          'Guía paso a paso sobre colocación de barra sobre trapecios, apertura de pies, profundidad adecuada rompiendo el paralelo y cómo evitar el colapso de rodillas (valgo).',
      infoEjercicio:
          'Músculos: Cuádriceps, glúteos, isquiotibiales, core. Nivel: Todos los niveles.',
      estado: 'Publicado',
    ),
    VideoModel(
      id: 'vid-03',
      titulo: 'Técnica de Peso Muerto',
      categoria: 'Espalda',
      duracion: '09:12',
      descripcion:
          'Dominá el bisagra de cadera, la tensión en dorsales y la posición neutral de la columna lumbar. Errores más comunes y cómo corregir el redondeo de espalda.',
      infoEjercicio:
          'Músculos: Erectores espinales, glúteos, isquiotibiales, antebrazos. Nivel: Intermedio-Avanzado.',
      estado: 'Publicado',
    ),
    VideoModel(
      id: 'vid-04',
      titulo: 'Curl de Bíceps',
      categoria: 'Brazos',
      duracion: '05:20',
      descripcion:
          'Secretos para aislar el bíceps braquial sin balancear el torso. Posición de codos, rango completo de movimiento y supinación en el punto máximo de contracción.',
      infoEjercicio:
          'Músculos: Bíceps braquial, braquiorradial. Nivel: Principiante.',
      estado: 'Publicado',
    ),
    VideoModel(
      id: 'vid-05',
      titulo: 'Press Militar con Barra',
      categoria: 'Hombros',
      duracion: '07:15',
      descripcion:
          'Técnica vertical de empuje por encima de la cabeza. Bloqueo de glúteos y abdomen para mantener la verticalidad y evitar hiperextensión lumbar.',
      infoEjercicio:
          'Músculos: Deltoides anterior y lateral, tríceps, trapecio. Nivel: Intermedio.',
      estado: 'Publicado',
    ),
    VideoModel(
      id: 'vid-06',
      titulo: 'HIIT Quema Grasa 15 min',
      categoria: 'Cardio',
      duracion: '15:00',
      descripcion:
          'Rutina cardiovascular de alta intensidad por intervalos. 40 segundos de trabajo activo por 20 de descanso con ejercicios pliométricos y funcionales.',
      infoEjercicio:
          'Acondicionamiento metabólico general y resistencia cardiovascular. Nivel: Todos.',
      estado: 'Publicado',
    ),
  ];

  List<VideoModel> get videos => List.unmodifiable(_videos);

  List<VideoModel> getVideos({String? categoria, String? query}) {
    return _videos.where((v) {
      final matchesCat = categoria == null ||
          categoria.toLowerCase() == 'todos' ||
          v.categoria.toLowerCase() == categoria.toLowerCase();
      final matchesQuery = query == null ||
          query.trim().isEmpty ||
          v.titulo.toLowerCase().contains(query.trim().toLowerCase()) ||
          v.categoria.toLowerCase().contains(query.trim().toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  void addVideo(VideoModel video) {
    _videos.insert(0, video);
  }

  void updateVideo(VideoModel video) {
    final index = _videos.indexWhere((v) => v.id == video.id);
    if (index != -1) {
      _videos[index] = video;
    }
  }

  void deleteVideo(String id) {
    _videos.removeWhere((v) => v.id == id);
  }
}
