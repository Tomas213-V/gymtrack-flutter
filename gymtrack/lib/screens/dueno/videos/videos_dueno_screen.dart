import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../repositories/video_repository.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/socio/socio_badge.dart';
import 'agregar_video_screen.dart';
import 'editar_video_screen.dart';

class VideosDuenoScreen extends StatefulWidget {
  const VideosDuenoScreen({super.key});

  @override
  State<VideosDuenoScreen> createState() => _VideosDuenoScreenState();
}

class _VideosDuenoScreenState extends State<VideosDuenoScreen> {
  final IVideoRepository _videoRepository = VideoRepository.instance;
  List<VideoModel> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVideos();
  }

  Future<void> _cargarVideos() async {
    setState(() => _isLoading = true);
    final lista = await _videoRepository.getVideos();
    if (!mounted) return;
    setState(() {
      _videos = lista;
      _isLoading = false;
    });
  }

  void _confirmarEliminarVideo(VideoModel video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar video?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${video.titulo}"?',
          style: const TextStyle(color: Color(0xFFCCCCCC)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              await _videoRepository.deleteVideo(video.id);
              await _cargarVideos();

              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Video eliminado correctamente'),
                  backgroundColor: Color(0xFF2E2E2E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navegarAAgregar() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AgregarVideoScreen()),
    );
    if (!mounted) return;
    if (result == true) {
      await _cargarVideos();
    }
  }

  Future<void> _navegarAEditar(VideoModel video) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditarVideoScreen(video: video)),
    );
    if (!mounted) return;
    if (result == true) {
      await _cargarVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Videos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAAgregar,
        backgroundColor: const Color(0xFF7DE610),
        foregroundColor: Colors.black,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtítulo
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Administrá el contenido para tus socios',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Lista de videos cargada dinámicamente desde el repositorio
            Expanded(
              child: _isLoading && _videos.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7DE610)),
                    )
                  : _videos.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay videos disponibles',
                            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _videos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            return _buildVideoCard(video);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail / Icono de Video
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Color(0xFF7DE610),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Título y categoría
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          SocioBadge(
                            text: video.categoria,
                            backgroundColor: const Color(0xFF2C2C2E),
                            textColor: const Color(0xFFCCCCCC),
                          ),
                          SocioBadge(
                            text: video.duracion,
                            backgroundColor: const Color(0xFF2C2C2E),
                            textColor: const Color(0xFF8E8E93),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Descripción resumida
            Text(
              video.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFF2C2C2E), height: 1),
            const SizedBox(height: 10),
            // Acciones: Editar y Eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _navegarAEditar(video),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF7DE610)),
                  label: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Color(0xFF7DE610),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmarEliminarVideo(video),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
