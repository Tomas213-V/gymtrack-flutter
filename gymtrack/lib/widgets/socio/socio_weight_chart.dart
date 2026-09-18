import 'package:flutter/material.dart';
import '../../models/socio_mock_models.dart';

class SocioWeightChart extends StatelessWidget {
  final List<ProgresoPuntoModel> puntos;

  const SocioWeightChart({
    super.key,
    required this.puntos,
  });

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) {
      return const SizedBox(height: 180);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF282828),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeightChartPainter(puntos: puntos),
            ),
          ),
          const SizedBox(height: 8),
          // Month labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: puntos.map((p) {
              return SizedBox(
                width: 44,
                child: Text(
                  p.mes,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<ProgresoPuntoModel> puntos;

  _WeightChartPainter({required this.puntos});

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.length < 2) return;

    final double minWeight = puntos.map((p) => p.peso).reduce((a, b) => a < b ? a : b) - 1.0;
    final double maxWeight = puntos.map((p) => p.peso).reduce((a, b) => a > b ? a : b) + 1.0;
    final double weightRange = (maxWeight - minWeight) == 0 ? 1.0 : (maxWeight - minWeight);

    final double paddingLeft = 20.0;
    final double paddingRight = 20.0;
    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - 15.0;

    // Draw horizontal faint guide lines
    final guidePaint = Paint()
      ..color = const Color(0xFF262626)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = chartHeight * (i / 3);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        guidePaint,
      );
    }

    final points = <Offset>[];
    final stepX = chartWidth / (puntos.length - 1);

    for (int i = 0; i < puntos.length; i++) {
      final x = paddingLeft + (i * stepX);
      // Invert Y because screen coordinates start at top
      // Note: in the visual reference, the line starts lower or higher. Let's map accurately.
      final normalized = (puntos[i].peso - minWeight) / weightRange;
      final y = chartHeight - (normalized * chartHeight) + 8;
      points.add(Offset(x, y));
    }

    // Path for gradient fill
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      fillPath.cubicTo(controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7DE610).withValues(alpha: 0.28),
          const Color(0xFF7DE610).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Path for line stroke
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      linePath.cubicTo(controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF7DE610)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Draw dots at each point
    final dotFillPaint = Paint()
      ..color = const Color(0xFF131313)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF7DE610)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final dotCenterPaint = Paint()
      ..color = const Color(0xFF7DE610)
      ..style = PaintingStyle.fill;

    for (final pt in points) {
      canvas.drawCircle(pt, 5.0, dotFillPaint);
      canvas.drawCircle(pt, 5.0, dotBorderPaint);
      canvas.drawCircle(pt, 2.2, dotCenterPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => true;
}
