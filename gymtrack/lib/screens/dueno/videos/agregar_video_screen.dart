import 'package:flutter/material.dart';
import '../../../mock/video_mock_data.dart';
import '../../../models/video_model.dart';
import '../../../theme/app_theme.dart';

class AgregarVideoScreen extends StatefulWidget {
  const AgregarVideoScreen({super.key});

  @override
  State<AgregarVideoScreen> createState() => _AgregarVideoScreenState();
}

class _AgregarVideoScreenState extends State<AgregarVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController(text: '08:00');
  final _urlController = TextEditingController(text: 'https://gymtrack.app/videos/tutorial');
  final _infoEjercicioController = TextEditingController();

  String _categoriaSeleccionada = 'Pecho';
  String _estadoSeleccionado = 'Publicado';

  final List<String> _categorias = [
    'Pecho',
    'Espalda',
    'Piernas',
    'Brazos',
    'Hombros',
    'Cardio',
    'General',
  ];

  final List<String> _estados = [
    'Publicado',
    'Borrador',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    _urlController.dispose();
    _infoEjercicioController.dispose();
    super.dispose();
  }

  void _guardarVideo() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nuevoVideo = VideoModel(
      id: 'vid-${DateTime.now().millisecondsSinceEpoch}',
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim().isNotEmpty
          ? _descripcionController.text.trim()
          : 'Instrucciones y técnica del ejercicio para miembros de GymTrack.',
      categoria: _categoriaSeleccionada,
      duracion: _duracionController.text.trim().isNotEmpty
          ? _duracionController.text.trim()
          : '05:00',
      url: _urlController.text.trim(),
      estado: _estadoSeleccionado,
      infoEjercicio: _infoEjercicioController.text.trim().isNotEmpty
          ? _infoEjercicioController.text.trim()
          : 'Músculos involucrados en el movimiento.',
    );

    VideoMockData().addVideo(nuevoVideo);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Video publicado correctamente',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(true);
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
          'Agregar Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Título del video
                _buildFieldLabel('Título del video *'),
                _buildTextFormField(
                  controller: _tituloController,
                  hintText: 'Ej: Técnica de Press de Banca',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa el título del video';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 2. Categoría
                _buildFieldLabel('Categoría *'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF282828)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categoriaSeleccionada,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7DE610)),
                      items: _categorias.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _categoriaSeleccionada = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Duración
                _buildFieldLabel('Duración (mm:ss) *'),
                _buildTextFormField(
                  controller: _duracionController,
                  hintText: '08:32',
                  keyboardType: TextInputType.datetime,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa la duración del video';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 4. URL del video
                _buildFieldLabel('URL del video'),
                _buildTextFormField(
                  controller: _urlController,
                  hintText: 'https://gymtrack.app/videos/...',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 18),

                // 5. Estado / publicación
                _buildFieldLabel('Estado'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF282828)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _estadoSeleccionado,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7DE610)),
                      items: _estados.map((est) {
                        return DropdownMenuItem<String>(
                          value: est,
                          child: Text(
                            est,
                            style: TextStyle(
                              color: est == 'Publicado' ? const Color(0xFF7DE610) : const Color(0xFFCCCCCC),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _estadoSeleccionado = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 6. Información del ejercicio
                _buildFieldLabel('Músculos / Información adicional'),
                _buildTextFormField(
                  controller: _infoEjercicioController,
                  hintText: 'Ej: Pectoral mayor, deltoides anterior, tríceps. Nivel: Intermedio.',
                ),
                const SizedBox(height: 18),

                // 7. Descripción
                _buildFieldLabel('Descripción'),
                _buildTextFormField(
                  controller: _descripcionController,
                  hintText: 'Detalla los pasos de ejecución, postura y tips...',
                  maxLines: 4,
                ),
                const SizedBox(height: 30),

                // Botón Publicar video
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _guardarVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7DE610),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Publicar video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF6E6E73),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFF1B1B1B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF282828)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF282828)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7DE610), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}
