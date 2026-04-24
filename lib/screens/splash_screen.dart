import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Stage 1: Text fades in slowly
  late Animation<double> _textOpacity;

  // Stage 2: Text lifts slightly as it appears
  late Animation<double> _textLift;

  // Stage 3: Arc draws itself
  late Animation<double> _arcProgress;

  // Stage 4: Arc rotates into position while drawing
  late Animation<double> _arcRotation;

  // Stage 5: Glow appears after arc completes
  late Animation<double> _glowOpacity;

  // Stage 6: Everything fades out
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    // Text appears slowly (0s → 2s)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    // Text lifts up slightly as it fades in
    _textLift = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    // Arc draws itself (1.5s → 3.5s)
    _arcProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.80, curve: Curves.easeInOut),
      ),
    );

    // Arc rotates slightly as it draws
    _arcRotation = Tween<double>(begin: -0.18, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    // Glow after arc completes (3.5s → 4s)
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.90, curve: Curves.easeIn),
      ),
    );

    // Fade out everything (4.2s → 5s)
    _fadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go('/');
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Logo color — bright blue on black looks best
    const logoColor = Color(0xFF4A6CF7);
    const logoColorDim = Color(0xFF2A4AD7);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: (1.0 - _fadeOut.value).clamp(0.0, 1.0),
            child: Stack(
              children: [
                // ── Background glow (appears with arc) ──
                Positioned.fill(
                  child: Opacity(
                    opacity: _glowOpacity.value * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.5, -0.4),
                          radius: 1.0,
                          colors: [
                            logoColor.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Center content ───────────────────────
                Center(
                  child: SizedBox(
                    width: screenSize.width * 0.80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Arc + Text stacked ───────────
                        SizedBox(
                          height: screenSize.height * 0.25,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // ── The Parabolic Arc ────────
                              Positioned.fill(
                                child: Transform.rotate(
                                  angle: _arcRotation.value,
                                  alignment: Alignment.bottomLeft,
                                  child: CustomPaint(
                                    painter: _ParabolicArcPainter(
                                      progress: _arcProgress.value,
                                      glowProgress: _glowOpacity.value,
                                      color: logoColor,
                                      dimColor: logoColorDim,
                                    ),
                                  ),
                                ),
                              ),

                              // ── YAKATS Text ──────────────
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: Offset(0, _textLift.value),
                                  child: Opacity(
                                    opacity: _textOpacity.value.clamp(0.0, 1.0),
                                    child: Text(
                                      'YAKATS',
                                      style: GoogleFonts.syncopate(
                                        color: Colors.white,
                                        fontSize: screenSize.width * 0.088,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: screenSize.width * 0.012,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Tagline ──────────────────────
                        Opacity(
                          opacity: (_glowOpacity.value).clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 8 * (1 - _glowOpacity.value)),
                            child: Text(
                              'Yapay Zeka Destekli Alerji Takip Sistemi',
                              style: GoogleFonts.syncopate(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: screenSize.width * 0.026,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PARABOLIC ARC PAINTER
//  - Starts bottom-left (near Y)
//  - Peaks at top-left (thickest point)
//  - Tapers toward bottom-right (near K)
//  - Draws itself progressively
//  - Rotates slightly into position
// ═══════════════════════════════════════════════════════════════

class _ParabolicArcPainter extends CustomPainter {
  final double progress;
  final double glowProgress;
  final Color color;
  final Color dimColor;

  _ParabolicArcPainter({
    required this.progress,
    required this.glowProgress,
    required this.color,
    required this.dimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // Arc definition:
    // Starts at bottom-left (near where Y starts in YAKATS)
    // Peaks high at top-left
    // Ends at bottom-right (near where K ends in YAKATS)
    final startPoint = Offset(size.width * 0.02, size.height * 0.90);
    final controlPoint = Offset(size.width * 0.14, -size.height * 0.18);
    final endPoint = Offset(size.width * 0.72, size.height * 0.55);

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

    // ── Glow pass (soft, wide, drawn behind) ────────────────
    if (glowProgress > 0) {
      final glowPath = metric.extractPath(0, totalLength * progress);

      canvas.drawPath(
        glowPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.12
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(0.07 * glowProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // ── Main arc — segmented for variable thickness ──────────
    const segments = 100;
    for (int i = 0; i < segments; i++) {
      final t0 = i / segments;
      final t1 = (i + 1) / segments;

      // Stop drawing beyond current progress
      if (t0 >= progress) break;

      final visibleT1 = math.min(t1, progress);
      final midT = (t0 + visibleT1) / 2;

      // Thickness profile:
      // Peaks at ~18% of the arc (just past the start)
      // which corresponds to the top-left corner of the parabola
      final thickness = _arcThickness(midT);

      final minStroke = size.width * 0.003;
      final maxStroke = size.width * 0.028;
      final strokeWidth = minStroke + (maxStroke - minStroke) * thickness;

      // Opacity also follows thickness
      final opacity = 0.2 + 0.8 * thickness;

      final segmentPath = metric.extractPath(
        totalLength * t0,
        totalLength * visibleT1,
      );

      canvas.drawPath(
        segmentPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(opacity.clamp(0.0, 1.0)),
      );
    }

    // ── Drawing head — glowing dot at the tip ────────────────
    if (progress > 0.01 && progress < 0.99) {
      final tangent = metric.getTangentForOffset(totalLength * progress);

      if (tangent != null) {
        final head = tangent.position;

        // Outer glow
        canvas.drawCircle(
          head,
          size.width * 0.022,
          Paint()
            ..color = color.withOpacity(0.25)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );

        // Inner bright dot
        canvas.drawCircle(
          head,
          size.width * 0.009,
          Paint()
            ..color = color.withOpacity(0.95)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  // Arc thickness profile
  // Uses an asymmetric bell curve
  // Peak is near the top-left (around t = 0.18)
  double _arcThickness(double t) {
    const peak = 0.18; // Where the arc is thickest
    const leftSpread = 0.18; // How fast it tapers from start to peak
    const rightSpread = 0.55; // How fast it tapers from peak to end

    final spread = t < peak ? leftSpread : rightSpread;
    final x = (t - peak) / spread;
    return math.exp(-(x * x));
  }

  @override
  bool shouldRepaint(covariant _ParabolicArcPainter old) {
    return old.progress != progress ||
        old.glowProgress != glowProgress ||
        old.color != color;
  }
}
