import 'package:flutter/material.dart';

class SocioBadge extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;
  final double fontSize;
  final EdgeInsets padding;

  const SocioBadge({
    super.key,
    required this.text,
    this.textColor = const Color(0xFF7DE610),
    this.borderColor = const Color(0xFF7DE610),
    this.backgroundColor = const Color(0xFF132B0F),
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  factory SocioBadge.active({String text = 'Activa'}) {
    return SocioBadge(
      text: text,
      textColor: const Color(0xFF7DE610),
      borderColor: const Color(0xFF7DE610).withValues(alpha: 0.8),
      backgroundColor: const Color(0xFF132B0F),
    );
  }

  factory SocioBadge.paid({String text = 'Pagado'}) {
    return SocioBadge(
      text: text,
      textColor: const Color(0xFF7DE610),
      borderColor: const Color(0xFF7DE610).withValues(alpha: 0.6),
      backgroundColor: const Color(0xFF132B0F),
    );
  }

  factory SocioBadge.pill({
    required String text,
    Color textColor = const Color(0xFF7DE610),
  }) {
    return SocioBadge(
      text: text,
      textColor: textColor,
      borderColor: textColor.withValues(alpha: 0.5),
      backgroundColor: textColor.withValues(alpha: 0.12),
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
