// File: lib/core/animations/ethiopian_background_animations.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class CalmBackground extends StatefulWidget {
  final Color color1; // Primary (e.g., Green)
  final Color color2; // Secondary (e.g., Yellow)
  final Color color3; // Tertiary (e.g., Red)
  final bool isDarkMode;

  const CalmBackground({
    super.key,
    this.color1 = const Color(0xFF009A44),
    this.color2 = const Color(0xFFFEDD00),
    this.color3 = const Color(0xFFD21034),
    required this.isDarkMode,
  });

  @override
  State<CalmBackground> createState() => _CalmBackgroundState();
}

class _CalmBackgroundState extends State<CalmBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Duration set to 20 seconds for a very smooth, non-rushed flow
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CalmWavesAndStarsPainter(
          animationValue: _controller,
          color1: widget.color1,
          color2: widget.color2,
          color3: widget.color3,
          isDarkMode: widget.isDarkMode,
        ),
        child: Container(),
      ),
    );
  }
}

class CalmWavesAndStarsPainter extends CustomPainter {
  final Animation<double> animationValue;
  final Color color1;
  final Color color2;
  final Color color3;
  final bool isDarkMode;

  // Static positions for the stars/crosses
  static final List<Offset> _starPositions = List.generate(
    12, // Slightly fewer items for a cleaner look
    (index) => Offset(
      math.Random(index).nextDouble(),
      math.Random(index * 100).nextDouble() * 0.8, // Keep stars in top 80%
    ),
  );

  CalmWavesAndStarsPainter({
    required this.animationValue,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.isDarkMode,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // 0. Background
    final bgPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final t = animationValue.value;

    // 1. Draw "Outlined Plus" Stars (Background Layer)
    // We draw these first so the waves appear in front of them
    _drawPlusStars(canvas, size, t);

    // 2. Draw Sine/Cosine Waves (Foreground Layer)
    // We offset them slightly so they don't perfectly overlap
    // Green (Top of the wave group)
    _drawWave(
      canvas,
      size,
      t,
      color1,
      speed: 1.0,
      offset: 0.0,
      heightShift: -15,
    );
    // Yellow (Middle)
    _drawWave(canvas, size, t, color2, speed: 0.7, offset: 2.0, heightShift: 0);
    // Red (Bottom of the wave group)
    _drawWave(
      canvas,
      size,
      t,
      color3,
      speed: 1.2,
      offset: 4.0,
      heightShift: 15,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double t,
    Color color, {
    required double speed,
    required double offset,
    required double heightShift,
  }) {
    final paint = Paint()
      ..color = color
          .withOpacity(0.25) // Slightly more visible than before
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          3.0 // Thicker lines for better visibility
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.solid,
        2,
      ); // Soft glow effect

    final path = Path();

    // KEY CHANGE: Lowering the center line.
    // 0.8 means 80% down the screen.
    final baseHeight = size.height * 0.82;
    final centerY = baseHeight + heightShift;

    for (double x = 0; x <= size.width; x += 5) {
      // Math improvements:
      // 1. Wider waves (x / 400)
      // 2. Smoother amplitude variation

      double y =
          centerY +
          // Primary large wave
          math.sin((x / 400) + (t * 2 * math.pi * speed) + offset) * 30 +
          // Secondary subtle ripple
          math.cos((x / 100) + (t * 2 * math.pi * (speed * 2))) * 8;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawPlusStars(Canvas canvas, Size size, double t) {
    const orangeColor = Color(0xFFFF9500);

    for (int i = 0; i < _starPositions.length; i++) {
      final posRatio = _starPositions[i];

      // Center of orbit
      final centerX = posRatio.dx * size.width;
      final centerY = posRatio.dy * size.height;

      // Motion parameters
      final orbitRadius = 20.0 + (i * 3.0);
      final orbitSpeed = 0.2 + (i * 0.05); // Slower orbit

      // Gentle Floating Motion
      final angle = (t * 2 * math.pi * orbitSpeed) + i;
      final dx = centerX + (math.cos(angle) * orbitRadius);
      final dy = centerY + (math.sin(angle) * orbitRadius);

      // Rotation of the shape itself (Slower rotation)
      final rotationAngle = t * 2 * math.pi * (0.5 + (i * 0.1));

      // Breathing/Pulsing
      final slowPulse = math.sin((t * 2 * math.pi) + i);
      final scale = 0.8 + (0.2 * slowPulse); // Scale between 0.8 and 1.0
      final opacity = 0.15 + (0.1 * slowPulse); // Faint opacity

      // Shape dimensions
      final baseSize = 18.0 * scale;
      final w = 3.0 * scale; // Thickness of the lines - increased gap

      final plusPaint = Paint()
        ..color = orangeColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.square;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(rotationAngle);
      canvas.translate(-dx, -dy);

      // --- Simple Plus Icon: 2 Vertical + 2 Horizontal Lines ---

      // Left vertical line
      canvas.drawLine(
        Offset(dx - w, dy - baseSize),
        Offset(dx - w, dy + baseSize),
        plusPaint,
      );

      // Right vertical line
      canvas.drawLine(
        Offset(dx + w, dy - baseSize),
        Offset(dx + w, dy + baseSize),
        plusPaint,
      );

      // Top horizontal line
      canvas.drawLine(
        Offset(dx - baseSize, dy - w),
        Offset(dx + baseSize, dy - w),
        plusPaint,
      );

      // Bottom horizontal line
      canvas.drawLine(
        Offset(dx - baseSize, dy + w),
        Offset(dx + baseSize, dy + w),
        plusPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CalmWavesAndStarsPainter oldDelegate) {
    return true;
  }
}
