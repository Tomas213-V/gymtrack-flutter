import 'package:flutter/material.dart';

class GymLogo extends StatelessWidget {
  final double size;

  const GymLogo({
    super.key,
    this.size = 135.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_verde.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: GymLogoPainter(),
        ),
      ),
    );
  }
}

class GymLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final scale = size.width / 140.0; // Escala base en 140px

    // 1. Fondo circular oscuro
    final bgPaint = Paint()
      ..color = const Color(0xFF161616)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, bgPaint);

    // 2. Anillo exterior verde
    final ringPaint = Paint()
      ..color = const Color(0xFF62C23C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - (5.5 * scale), ringPaint);

    // 3. Destellos amarillos arriba
    final sparkPaint = Paint()
      ..color = const Color(0xFFF9C032)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2 * scale
      ..strokeCap = StrokeCap.round;

    // Destello central
    canvas.drawLine(
      Offset(center.dx, center.dy - (48 * scale)),
      Offset(center.dx, center.dy - (41 * scale)),
      sparkPaint,
    );
    // Destello izquierdo
    canvas.drawLine(
      Offset(center.dx - (13 * scale), center.dy - (45 * scale)),
      Offset(center.dx - (8 * scale), center.dy - (39 * scale)),
      sparkPaint,
    );
    // Destello derecho
    canvas.drawLine(
      Offset(center.dx + (13 * scale), center.dy - (45 * scale)),
      Offset(center.dx + (8 * scale), center.dy - (39 * scale)),
      sparkPaint,
    );

    // 4. Silueta inferior de Kettlebell (Pesa rusa verde)
    final kettlebellPaint = Paint()
      ..color = const Color(0xFF5AB637)
      ..style = PaintingStyle.fill;

    final kettlePath = Path();
    // Cuerpo y asa de la pesa rusa abajo
    final kCenter = Offset(center.dx, center.dy + (35 * scale));
    kettlePath.addOval(Rect.fromCenter(
      center: kCenter,
      width: 58 * scale,
      height: 48 * scale,
    ));

    // Hueco del asa
    final handleHole = Path();
    handleHole.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy + (26 * scale)),
      width: 26 * scale,
      height: 20 * scale,
    ));

    final finalKettlePath = Path.combine(
      PathOperation.difference,
      kettlePath,
      handleHole,
    );

    // Clip con el círculo interior para que no se salga del borde
    canvas.save();
    final innerClip = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - (10 * scale)));
    canvas.clipPath(innerClip);
    canvas.drawPath(finalKettlePath, kettlebellPaint);
    canvas.restore();

    // 5. Figura izquierda (Naranja)
    final orangePaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    // Cabeza naranja
    canvas.drawCircle(
      Offset(center.dx - (25 * scale), center.dy - (24 * scale)),
      9.0 * scale,
      orangePaint,
    );

    // Cuerpo y brazo naranja
    final orangeBody = Path();
    orangeBody.moveTo(center.dx - (35 * scale), center.dy + (10 * scale));
    orangeBody.quadraticBezierTo(
      center.dx - (38 * scale),
      center.dy - (12 * scale),
      center.dx - (23 * scale),
      center.dy - (10 * scale),
    );
    // Brazo extendiéndose hacia el centro
    orangeBody.quadraticBezierTo(
      center.dx - (10 * scale),
      center.dy - (6 * scale),
      center.dx + (2 * scale),
      center.dy - (3 * scale),
    );
    // Mano/apretón
    orangeBody.quadraticBezierTo(
      center.dx - (4 * scale),
      center.dy + (7 * scale),
      center.dx - (14 * scale),
      center.dy + (6 * scale),
    );
    // Torso volviendo abajo
    orangeBody.quadraticBezierTo(
      center.dx - (24 * scale),
      center.dy + (16 * scale),
      center.dx - (35 * scale),
      center.dy + (10 * scale),
    );
    orangeBody.close();
    canvas.drawPath(orangeBody, orangePaint);

    // 6. Figura derecha (Blanca)
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Cabeza blanca
    canvas.drawCircle(
      Offset(center.dx + (25 * scale), center.dy - (24 * scale)),
      9.0 * scale,
      whitePaint,
    );

    // Cuerpo y brazo blanco
    final whiteBody = Path();
    whiteBody.moveTo(center.dx + (35 * scale), center.dy + (10 * scale));
    whiteBody.quadraticBezierTo(
      center.dx + (38 * scale),
      center.dy - (12 * scale),
      center.dx + (23 * scale),
      center.dy - (10 * scale),
    );
    // Brazo hacia el centro entrelazándose
    whiteBody.quadraticBezierTo(
      center.dx + (10 * scale),
      center.dy - (6 * scale),
      center.dx - (2 * scale),
      center.dy - (1 * scale),
    );
    // Mano/apretón
    whiteBody.quadraticBezierTo(
      center.dx + (4 * scale),
      center.dy + (9 * scale),
      center.dx + (14 * scale),
      center.dy + (6 * scale),
    );
    // Torso volviendo abajo
    whiteBody.quadraticBezierTo(
      center.dx + (24 * scale),
      center.dy + (16 * scale),
      center.dx + (35 * scale),
      center.dy + (10 * scale),
    );
    whiteBody.close();
    canvas.drawPath(whiteBody, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
