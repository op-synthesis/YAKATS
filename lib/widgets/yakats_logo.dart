import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════
//  YAKATS LOGO — Home Screen Version
//  Arc sits at top-left corner
//  YAKATS text sits inside the arc curve
// ═══════════════════════════════════════════════════════════════

class YakatsLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showText;

  const YakatsLogo({
    Key? key,
    this.size = 100,
    this.color,
    this.showText = true,
  }) : super(key: key);

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF4A6CF7) : const Color(0xFF0F2A78);
  }

  @override
  Widget build(BuildContext context) {
    final logoColor = _resolveColor(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Arc in top-left corner
          Positioned.fill(
            child: CustomPaint(painter: _CornerArcPainter(color: logoColor)),
          ),

          // YAKATS text inside the arc
          if (showText)
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0.1, 0.2),
                child: Text(
                  'YAKATS',
                  style: GoogleFonts.syncopate(
                    color: logoColor,
                    fontSize: size * 0.165,
                    fontWeight: FontWeight.bold,
                    letterSpacing: size * 0.018,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Corner Arc Painter ────────────────────────────────────────
// Arc origin is at top-left corner of the widget
// Curves from bottom-left to top-right
// Thickest at the corner (top-left), tapering toward both ends
class _CornerArcPainter extends CustomPainter {
  final Color color;

  _CornerArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Arc starts at bottom-left edge
    final startPoint = Offset(0, size.height * 0.85);

    // Control point pushes arc toward top-left
    final controlPoint = Offset(size.width * 0.08, size.height * 0.08);

    // Arc ends at top-right edge
    final endPoint = Offset(size.width * 0.88, 0);

    final path = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final totalLength = metric.length;

    // Soft glow layer
    canvas.drawPath(
      metric.extractPath(0, totalLength),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.10
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Main segmented arc (variable thickness)
    const segments = 60;
    for (int i = 0; i < segments; i++) {
      final t0 = i / segments;
      final t1 = (i + 1) / segments;
      final midT = (t0 + t1) / 2;

      // Peak thickness at the corner (t ≈ 0.20)
      final thickness = _bellCurve(midT, peak: 0.20, spread: 0.22);

      final minStroke = size.width * 0.008;
      final maxStroke = size.width * 0.055;
      final strokeWidth = minStroke + (maxStroke - minStroke) * thickness;

      final opacity = 0.18 + 0.82 * thickness;

      canvas.drawPath(
        metric.extractPath(totalLength * t0, totalLength * t1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(opacity.clamp(0.0, 1.0)),
      );
    }
  }

  double _bellCurve(double t, {required double peak, required double spread}) {
    final x = (t - peak) / spread;
    return math.exp(-(x * x));
  }

  @override
  bool shouldRepaint(_CornerArcPainter old) => old.color != color;
}
