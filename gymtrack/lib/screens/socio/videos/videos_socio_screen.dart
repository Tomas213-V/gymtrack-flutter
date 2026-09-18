import 'package:flutter/material.dart';
import '../../../mock/video_mock_data.dart';
import '../../../models/video_model.dart';
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
  final _mockData = VideoMockData();

  String _categoriaActiva = 'Todos';
  String _query = '';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videosFiltrados = _mockData.getVideos(
      categoria: _categoriaActiva,
      query: _query,
    );

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
                    setState(() {
                      _query = val;
                    });
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
                              setState(() {
                                _query = '';
                              });
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
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _categoriaActiva = cat;
                          });
                        }
                      },
                      selectedColor: const Color(0xFF7DE610),
                      backgroundColor: const Color(0xFF1E1E1E),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF7DE610) : const Color(0xFF2E2E2E),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Lista de videos disponibles para el socio
            Expanded(
              child: videosFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 56,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No se encontraron videos',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Probá buscando con otra palabra o categoría.',
                            style: TextStyle(
                              color: Color(0xFF6E6E73),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      itemCount: videosFiltrados.length,
                      itemBuilder: (context, index) {
                        final video = videosFiltrados[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildSocioVideoCard(video),
                        );
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
            // Portada de video con botón play y duración
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
                // Categoría
                Positioned(
                  top: 12,
                  left: 12,
                  child: SocioBadge.pill(
                    text: video.categoria,
                    textColor: const Color(0xFF7DE610),
                  ),
                ),
                // Duración
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

            // Título e info resumida
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${video.categoria} · ${video.duracion}',
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF6E6E73),
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
