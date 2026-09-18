import 'package:flutter/material.dart';
import '../../../mock/video_mock_data.dart';
import '../../../models/video_model.dart';
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
  final _mockData = VideoMockData();

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
            onPressed: () {
              Navigator.of(context).pop();
              _mockData.deleteVideo(video.id);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
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
    if (result == true || mounted) {
      setState(() {});
    }
  }

  Future<void> _navegarAEditar(VideoModel video) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditarVideoScreen(video: video)),
    );
    if (result == true || mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final videos = _mockData.videos;

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

            // Lista de videos
            Expanded(
              child: videos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No hay videos cargados',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Presioná el botón "+" para publicar tu primer video.',
                            style: TextStyle(
                              color: Color(0xFF6E6E73),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildVideoCard(video),
                        );
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
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF282828),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Thumbnail con botón de reproducción y duración
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF141414),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7DE610).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF7DE610).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF7DE610),
                      size: 30,
                    ),
                  ),
                ),
              ),
              // Badge de Categoría arriba a la izquierda
              Positioned(
                top: 12,
                left: 12,
                child: SocioBadge.pill(
                  text: video.categoria,
                  textColor: const Color(0xFF7DE610),
                ),
              ),
              // Duración abajo a la derecha
              Positioned(
                bottom: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        video.duracion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Información del video y acciones
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        video.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SocioBadge.active(text: video.estado),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${video.categoria} · ${video.duracion}',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF282828), height: 1),
                const SizedBox(height: 8),

                // Botones Editar y Eliminar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Editar
                    TextButton.icon(
                      onPressed: () => _navegarAEditar(video),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: Color(0xFF7DE610),
                      ),
                      label: const Text(
                        'Editar',
                        style: TextStyle(
                          color: Color(0xFF7DE610),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botón Eliminar
                    TextButton.icon(
                      onPressed: () => _confirmarEliminarVideo(video),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Color(0xFFEF4444),
                      ),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
