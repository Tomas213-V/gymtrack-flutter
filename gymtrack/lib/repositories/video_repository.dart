import '../mock/video_mock_data.dart';
import '../models/video_model.dart';

/// Contrato abstracto para la gestión de Videos (Patrón Repository)
abstract class IVideoRepository {
  /// Obtiene la lista de videos aplicando filtros opcionales de categoría y búsqueda
  Future<List<VideoModel>> getVideos({String? categoria, String? query});

  /// Busca un video por su identificador único
  Future<VideoModel?> getVideoById(String id);

  /// Agrega un nuevo video a la fuente de datos
  Future<VideoModel> addVideo(VideoModel video);

  /// Actualiza los datos de un video existente
  Future<VideoModel> updateVideo(VideoModel video);

  /// Elimina un video por su identificador único
  Future<bool> deleteVideo(String id);

  /// Obtiene las categorías de videos disponibles en la plataforma
  Future<List<String>> getCategorias();
}

/// Implementación concreta del repositorio de videos.
/// Conecta la capa de presentación con el origen de datos (Mock en memoria y/o API).
class VideoRepository implements IVideoRepository {
  static final VideoRepository _instance = VideoRepository._internal();
  factory VideoRepository() => _instance;
  static VideoRepository get instance => _instance;

  VideoRepository._internal();

  final VideoMockData _dataSource = VideoMockData();

  @override
  Future<List<VideoModel>> getVideos({String? categoria, String? query}) async {
    // Simulación de carga asíncrona no bloqueante
    await Future.microtask(() {});
    return _dataSource.getVideos(categoria: categoria, query: query);
  }

  @override
  Future<VideoModel?> getVideoById(String id) async {
    await Future.microtask(() {});
    try {
      return _dataSource.videos.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<VideoModel> addVideo(VideoModel video) async {
    await Future.microtask(() {});
    _dataSource.addVideo(video);
    return video;
  }

  @override
  Future<VideoModel> updateVideo(VideoModel video) async {
    await Future.microtask(() {});
    _dataSource.updateVideo(video);
    return video;
  }

  @override
  Future<bool> deleteVideo(String id) async {
    await Future.microtask(() {});
    final initialCount = _dataSource.videos.length;
    _dataSource.deleteVideo(id);
    return _dataSource.videos.length < initialCount;
  }

  @override
  Future<List<String>> getCategorias() async {
    return const [
      'Todos',
      'Pecho',
      'Espalda',
      'Piernas',
      'Brazos',
      'Hombros',
      'Cardio',
    ];
  }
}

