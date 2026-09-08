import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoogleSignInSection extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInSection({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Continuar con',
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onPressed ?? () {},
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(32, 32),
                painter: GoogleLogoPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Arcos de la G de Google
    // Azul: desde -45° hasta 45°
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.5, false, bluePaint);

    // Verde: desde 45° hasta 135°
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.5, false, greenPaint);

    // Amarillo: desde 135° hasta 225°
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 0.5, false, yellowPaint);

    // Rojo: desde 225° hasta 315°
    canvas.drawArc(rect, math.pi * 1.25, math.pi * 0.5, false, redPaint);

    // Barra horizontal azul de la 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      center.dx - (strokeWidth * 0.2),
      center.dy - (strokeWidth / 2),
      radius + (strokeWidth * 0.2),
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
