import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/socio/socio_badge.dart';

class DetalleVideoScreen extends StatelessWidget {
  final VideoModel video;

  const DetalleVideoScreen({
    super.key,
    required this.video,
  });

  void _simularReproduccion(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF7DE610)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reproduciendo: ${video.titulo}\n(Reproductor próximamente disponible)',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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
          'Detalle del video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reproductor simulado / Portada
                    InkWell(
                      onTap: () => _simularReproduccion(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF282828),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Botón de play grande en el centro
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7DE610).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF7DE610),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF7DE610),
                                  size: 40,
                                ),
                              ),
                            ),
                            // Píldora de duración
                            Positioned(
                              bottom: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 13, color: Colors.white70),
                                    const SizedBox(width: 5),
                                    Text(
                                      video.duracion,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Badges de categoría y estado
                    Row(
                      children: [
                        SocioBadge.pill(text: video.categoria),
                        const SizedBox(width: 8),
                        SocioBadge.pill(
                          text: video.duracion,
                          textColor: const Color(0xFF38BDF8),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Título
                    Text(
                      video.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Sección Descripción
                    const Text(
                      'DESCRIPCIÓN',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.descripcion,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Sección Información del ejercicio
                    if (video.infoEjercicio.isNotEmpty) ...[
                      const Text(
                        'INFORMACIÓN DEL EJERCICIO',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B1B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF282828)),
                        ),
                        child: Text(
                          video.infoEjercicio,
                          style: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // Botón inferior Reproducir video
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _simularReproduccion(context),
                  icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.black, size: 22),
                  label: const Text(
                    'Reproducir video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DE610),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
