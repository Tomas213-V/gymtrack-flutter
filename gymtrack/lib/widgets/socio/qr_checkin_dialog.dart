import 'package:flutter/material.dart';
import '../../services/socio_dashboard_service.dart';


class QrCheckinDialog extends StatefulWidget {
  final VoidCallback? onCheckinExitoso;

  const QrCheckinDialog({
    super.key,
    this.onCheckinExitoso,
  });

  static Future<bool?> show(BuildContext context, {VoidCallback? onCheckinExitoso}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrCheckinDialog(onCheckinExitoso: onCheckinExitoso),
    );
  }

  @override
  State<QrCheckinDialog> createState() => _QrCheckinDialogState();
}

class _QrCheckinDialogState extends State<QrCheckinDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _manualCodeController = TextEditingController();
  final SocioDashboardService _dashboardService = SocioDashboardService();

  late AnimationController _animationController;
  late Animation<double> _laserAnimation;

  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  bool _mostrarEntradaManual = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _procesarCheckin(String rawData) async {
    if (rawData.trim().isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresá un código válido.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final res = await _dashboardService.registrarCheckin(
      qrData: rawData.trim(),
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (res['success'] == true) {
      setState(() {
        _successMessage = res['mensaje'] ?? '¡Asistencia registrada con éxito!';
      });

      if (widget.onCheckinExitoso != null) {
        widget.onCheckinExitoso!();
      }

      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _errorMessage = res['error'] ?? 'No se pudo verificar el código QR.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A), width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7DE610).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF7DE610),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in de Asistencia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Escaneá el código QR del gimnasio',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Mensaje de éxito
            if (_successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7DE610).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF7DE610), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF7DE610), size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Mensaje de error
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEF4444), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFEF4444), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Visor Escáner QR Animado
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF282828), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Esquinas de escaneo
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: CustomPaint(
                        painter: ScannerFramePainter(),
                      ),
                    ),
                  ),

                  // Animación de línea láser
                  if (_successMessage == null)
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 30 + (_laserAnimation.value * 180),
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7DE610),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7DE610).withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Icono central o indicador de carga
                  if (_isProcessing)
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF7DE610),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Verificando código...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else if (_successMessage != null)
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          color: Color(0xFF7DE610),
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '¡Entrenamiento listo!',
                          style: TextStyle(
                            color: Color(0xFF7DE610),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          color: const Color(0xFF7DE610).withValues(alpha: 0.7),
                          size: 72,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Apunta al QR del gimnasio',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón de Escaneo Rápido (Detecta automáticamente el QR del gimnasio)
            if (_successMessage == null) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _procesarCheckin('GYMTRACK:CHECKIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DE610),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 20),
                  label: const Text(
                    'Simular / Detectar QR Inmediato',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Toggle Entrada manual de código
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _mostrarEntradaManual = !_mostrarEntradaManual;
                  });
                },
                icon: Icon(
                  _mostrarEntradaManual
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_outlined,
                  color: const Color(0xFF8E8E93),
                  size: 18,
                ),
                label: Text(
                  _mostrarEntradaManual
                      ? 'Ocultar código manual'
                      : '¿No funciona la cámara? Ingresar código',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
              ),

              if (_mostrarEntradaManual) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualCodeController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Ej: GYM-01 o ID de gym',
                          hintStyle: const TextStyle(color: Color(0xFF666666)),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF7DE610)),
                          ),
                        ),
                        onSubmitted: (val) => _procesarCheckin(val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _procesarCheckin(_manualCodeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7DE610)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
