// File: lib/core/animations/ethiopian_background_animations.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom painter that draws stylized Ethiopian traditional patterns (Tibeb/Mesob concepts)
/// Animated and adaptable to theme colors.
class EthiopianGeometricPainter extends CustomPainter {
  final double animationValue;
  final Color color1; // Usually Green or Primary
  final Color color2; // Usually Yellow or Secondary
  final Color color3; // Usually Red or Tertiary
  final bool isDarkMode;

  EthiopianGeometricPainter(
    this.animationValue,
    this.color1,
    this.color2,
    this.color3,
    this.isDarkMode,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height);

    // 1. Draw Background
    final bgPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw Rotating Arcs (Abstract Representation of Unity)
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Layer 1: Color 1 (Green/Primary)
    paint.color = color1.withOpacity(0.05);
    _drawGeometricLayer(canvas, center, radius * 0.8, 3, animationValue, paint);

    // Layer 2: Color 2 (Yellow/Secondary)
    paint.color = color2.withOpacity(0.05);
    _drawGeometricLayer(
      canvas,
      center,
      radius * 0.6,
      5,
      -animationValue * 0.8,
      paint,
    );

    // Layer 3: Color 3 (Red/Tertiary)
    paint.color = color3.withOpacity(0.05);
    _drawGeometricLayer(
      canvas,
      center,
      radius * 0.4,
      7,
      animationValue * 1.2,
      paint,
    );

    // 3. Draw subtle Mesob-like circular patterns
    _drawMesobPattern(canvas, center, size, isDarkMode);
  }

  void _drawGeometricLayer(
    Canvas canvas,
    Offset center,
    double radius,
    int sides,
    double rotation,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) + rotation;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMesobPattern(Canvas canvas, Offset center, Size size, bool isDark) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.03);

    // Draw concentric subtle circles
    for (int i = 1; i < 5; i++) {
      double r = (size.width / 6) * i + (math.sin(animationValue + i) * 10);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant EthiopianGeometricPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
