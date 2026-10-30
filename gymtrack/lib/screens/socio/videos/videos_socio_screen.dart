import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../repositories/video_repository.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/socio/socio_badge.dart';
import 'detalle_video_screen.dart';

class VideosSocioScreen extends StatefulWidget {
  final bool showBackButton;

  const VideosSocioScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<VideosSocioScreen> createState() => _VideosSocioScreenState();
}

class _VideosSocioScreenState extends State<VideosSocioScreen> {
  final _searchController = TextEditingController();
  final IVideoRepository _videoRepository = VideoRepository.instance;

  String _categoriaActiva = 'Todos';
  String _query = '';
  List<VideoModel> _videos = [];
  bool _isLoading = false;

  final List<String> _categorias = [
    'Todos',
    'Pecho',
    'Espalda',
    'Piernas',
    'Brazos',
    'Hombros',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _cargarVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarVideos() async {
    setState(() => _isLoading = true);
    final lista = await _videoRepository.getVideos(
      categoria: _categoriaActiva,
      query: _query,
    );
    if (!mounted) return;
    setState(() {
      _videos = lista;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videosFiltrados = _videos;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtítulo
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Text(
                'Aprendé y mejorá tu técnica',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF282828)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (val) {
                    _query = val;
                    _cargarVideos();
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar videos por título o grupo muscular...',
                    hintStyle: const TextStyle(color: Color(0xFF6E6E73), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7DE610), size: 22),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF8E8E93), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _query = '';
                              _cargarVideos();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Chips horizontales de categorías
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final isSelected = _categoriaActiva.toLowerCase() == cat.toLowerCase();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF7DE610),
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF2C2C2E),
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          _categoriaActiva = cat;
                          _cargarVideos();
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Listado de videos
            Expanded(
              child: _isLoading && videosFiltrados.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7DE610)),
                    )
                  : videosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.videocam_off_outlined, color: Color(0xFF48484A), size: 54),
                              const SizedBox(height: 12),
                              const Text(
                                'No se encontraron videos',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _query.isNotEmpty
                                    ? 'No hay resultados para "$_query"'
                                    : 'No hay videos en la categoría seleccionada',
                                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: videosFiltrados.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final video = videosFiltrados[index];
                            return _buildSocioVideoCard(video);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocioVideoCard(VideoModel video) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetalleVideoScreen(video: video),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  // Play Thumbnail
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Color(0xFF7DE610),
                        size: 30,
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
              // Descripción
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
              const SizedBox(height: 12),
              // Hint visual para ver más
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver detalle',
                    style: TextStyle(
                      color: Color(0xFF7DE610),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF7DE610), size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
