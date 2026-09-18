import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'dueno/videos/videos_dueno_screen.dart';

class MenuSeccionesScreen extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onOpenGymProfile;

  const MenuSeccionesScreen({
    super.key,
    this.user,
    this.onOpenGymProfile,
  });

  void _showEjerciciosModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161D21),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fitness_center, color: Color(0xFF00E676), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Rutinas y Ejercicios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionItem(
                    icon: Icons.splitscreen_rounded,
                    title: 'Rutina Hipertrofia A/B/C',
                    subtitle: '4 días por semana • Nivel Intermedio',
                    badge: 'Popular',
                  ),
                  _buildSectionItem(
                    icon: Icons.directions_run_rounded,
                    title: 'Circuito Funcional & Cardio',
                    subtitle: '30 minutos • Quema calórica',
                    badge: 'Cardio',
                  ),
                  _buildSectionItem(
                    icon: Icons.bolt_rounded,
                    title: 'Fuerza Máxima 5x5',
                    subtitle: '3 días por semana • Nivel Avanzado',
                    badge: 'Fuerza',
                  ),
                  _buildSectionItem(
                    icon: Icons.self_improvement_rounded,
                    title: 'Movilidad y Estiramientos',
                    subtitle: 'Recuperación activa y flexibilidad',
                    badge: 'Salud',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPerfilGimnasioModal(BuildContext context) {
    final gym = user?.gimnasio;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161D21),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF00E676), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gym?.nombre ?? 'Mi Gimnasio',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sede principal activa',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF243037)),
              const SizedBox(height: 14),
              _buildGymDetailRow(Icons.location_on_outlined, 'Dirección', gym?.direccion ?? 'No especificada'),
              const SizedBox(height: 12),
              _buildGymDetailRow(Icons.phone_outlined, 'Teléfono', gym?.telefono ?? 'No registrado'),
              const SizedBox(height: 12),
              _buildGymDetailRow(Icons.access_time_rounded, 'Horarios', 'Lunes a Viernes: 07:00 a 22:00\nSábados: 09:00 a 18:00'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: const Text('Entendido', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showSoporteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161D21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF00E676), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Centro de Soporte',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Estamos para ayudarte en todo momento',
                        style: TextStyle(fontSize: 13, color: Color(0xFF8A98A0)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 22),
                ),
                title: const Text('WhatsApp Soporte GymTrack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Respuesta inmediata de 8:00 a 20:00', style: TextStyle(color: Color(0xFF8A98A0), fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A8B94)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conectando con soporte de GymTrack...'),
                      backgroundColor: Color(0xFF1B5E20),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFF243037)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email_outlined, color: Color(0xFF38BDF8), size: 22),
                ),
                title: const Text('Correo Electrónico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('soporte@gymtrack.app', style: TextStyle(color: Color(0xFF8A98A0), fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A8B94)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email de soporte copiado: soporte@gymtrack.app'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildGymDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E676), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A98A0))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E282D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3840)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00E676), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A98A0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Encabezado principal
            const Text(
              'Menú de Secciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Accede a tus opciones adicionales',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A98A0),
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 28),

            // 1. Tarjeta de Videos
            _buildOptionCard(
              context: context,
              icon: Icons.play_circle_outline_rounded,
              title: 'Videos',
              subtitle: 'Administrá el contenido para tus\nsocios',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const VideosDuenoScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            // 2. Tarjeta de Ejercicios
            _buildOptionCard(
              context: context,
              icon: Icons.link_rounded,
              title: 'Ejercicios',
              subtitle: 'Ver tus rutinas y planes de\nentrenamiento',
              onTap: () => _showEjerciciosModal(context),
            ),

            const SizedBox(height: 16),

            // 2. Tarjeta Perfil del Gimnasio
            _buildOptionCard(
              context: context,
              icon: Icons.inventory_2_outlined,
              title: 'Perfil del gimnasio',
              subtitle: 'Información de la sede, horarios\ny servicios',
              onTap: () => _showPerfilGimnasioModal(context),
            ),

            const SizedBox(height: 16),

            // 3. Tarjeta Contactar Soporte
            _buildOptionCard(
              context: context,
              icon: Icons.headset_mic_outlined,
              title: 'Contactar soporte',
              subtitle: 'Enviar consultas o reportar\nproblemas',
              onTap: () => _showSoporteModal(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161D21),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF243037),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFF00E676).withValues(alpha: 0.1),
          highlightColor: const Color(0xFF00E676).withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Círculo con borde brillante e icono en verde neón
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E676).withValues(alpha: 0.12),
                        border: Border.all(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: const Color(0xFF00E676),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Título en verde neón destacado
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E676),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtítulo descriptivo centrado
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB0BEC5),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),

                // Flecha chevron hacia la derecha
                const Positioned(
                  right: 4,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF7A8B94),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
