import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/asistencia_service.dart';

class QrGimnasioDialog extends StatefulWidget {
  final int? idGimnasio;
  final String? nombreGimnasio;

  const QrGimnasioDialog({
    super.key,
    this.idGimnasio,
    this.nombreGimnasio,
  });

  static Future<void> show(
    BuildContext context, {
    int? idGimnasio,
    String? nombreGimnasio,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => QrGimnasioDialog(
        idGimnasio: idGimnasio,
        nombreGimnasio: nombreGimnasio,
      ),
    );
  }

  @override
  State<QrGimnasioDialog> createState() => _QrGimnasioDialogState();
}

class _QrGimnasioDialogState extends State<QrGimnasioDialog> {
  final AsistenciaService _asistenciaService = AsistenciaService();
  bool _isLoading = true;
  String _codigoQr = 'GYMTRACK:1';
  String _nombreGimnasio = 'GymTrack Fitness';

  @override
  void initState() {
    super.initState();
    _cargarQrData();
  }

  Future<void> _cargarQrData() async {
    final res = await _asistenciaService.getQRGimnasio();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res != null) {
        _codigoQr = res['codigo_qr'] ?? 'GYMTRACK:${widget.idGimnasio ?? 1}';
        _nombreGimnasio = res['nombre_gimnasio'] ?? (widget.nombreGimnasio ?? 'GymTrack Fitness');
      } else {
        _codigoQr = 'GYMTRACK:${widget.idGimnasio ?? 1}';
        _nombreGimnasio = widget.nombreGimnasio ?? 'GymTrack Fitness';
      }
    });
  }

  void _copiarCodigo() {
    Clipboard.setData(ClipboardData(text: _codigoQr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Código de ingreso copiado al portapapeles!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF7DE610),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                          Icons.qr_code_2_rounded,
                          color: Color(0xFF7DE610),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QR de Asistencia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _nombreGimnasio,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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

            // Card con código QR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7DE610).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),

              child: _isLoading
                  ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    )
                  : QrImageView(
                      data: _codigoQr,
                      version: QrVersions.auto,
                      size: 210,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Código en texto para copiar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF202020),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D2D2D)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key_rounded,
                          color: Color(0xFF7DE610), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _codigoQr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _copiarCodigo,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded,
                              color: Color(0xFF7DE610), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Copiar',
                            style: TextStyle(
                              color: Color(0xFF7DE610),
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
            const SizedBox(height: 16),

            // Instrucciones para el dueño
            const Text(
              'Mostrá este código en recepción o mostrador. Los socios pueden escanearlo desde su app para registrar su asistencia al instante.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Botón Cerrar
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Listo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
