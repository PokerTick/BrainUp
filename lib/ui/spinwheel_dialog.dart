import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

// ─── Spin Wheel Segments ────────────────────────────────────────────────────
//
// Probabilitas dari backend:
//   5%  Discount → 30% chance  → largest slice
//  10%  Discount → 40% chance  → largest slice
//  20%  Discount → 15% chance
//  25%  Discount → 10% chance
//  30%  Discount →  5% chance  → smallest slice
//
// Angle share = probability / 100

class _WheelSegment {
  final int discount;      // discount percentage won
  final double probability; // probability share (0–1)
  final Color color;

  const _WheelSegment({
    required this.discount,
    required this.probability,
    required this.color,
  });

  double get sweepAngle => probability * 2 * math.pi;
}

const _segments = [
  _WheelSegment(discount: 5,  probability: 0.30, color: Color(0xFF7C3AED)),
  _WheelSegment(discount: 10, probability: 0.40, color: Color(0xFF4F46E5)),
  _WheelSegment(discount: 20, probability: 0.15, color: Color(0xFF0EA5E9)),
  _WheelSegment(discount: 25, probability: 0.10, color: Color(0xFF10B981)),
  _WheelSegment(discount: 30, probability: 0.05, color: Color(0xFFF59E0B)),
];

// ─── Spin Wheel Dialog ──────────────────────────────────────────────────────

class SpinwheelDialog extends StatefulWidget {
  const SpinwheelDialog({super.key});

  @override
  State<SpinwheelDialog> createState() => _SpinwheelDialogState();
}

class _SpinwheelDialogState extends State<SpinwheelDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  bool _isSpinning = false;
  bool _hasResult = false;
  String? _errorMsg;
  Map<String, dynamic>? _spinResult;

  // The angle the wheel rests at after spinning (determines which segment is shown)
  double _currentAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Core spin logic ─────────────────────────────────────────────────────

  Future<void> _spin() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _hasResult = false;
      _errorMsg = null;
      _spinResult = null;
    });

    // 1. Hit API while wheel starts spinning
    final apiResultFuture = ApiService.spinGacha();

    // 2. Kick off a "suspense" spin: 5–7 full rotations + random partial
    const extraRotations = 6.0;
    final suspenseTarget = _currentAngle + (extraRotations * 2 * math.pi);

    _rotationAnimation = Tween<double>(
      begin: _currentAngle,
      end: suspenseTarget,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller
      ..reset()
      ..forward();

    // 3. Wait for both: animation half-point + API result
    final apiResult = await apiResultFuture;

    // 4. After suspense spin, land on the correct segment (or random if error)
    await _controller.forward(from: 0);

    // Determine which segment to land on
    int discountPct = 0;
    String? errorMsg;

    if (apiResult != null && apiResult['error'] == null) {
      final coupon = apiResult['coupon'] as Map<String, dynamic>?;
      discountPct = (coupon?['discountPct'] as num?)?.toInt() ??
          (apiResult['discountPct'] as num?)?.toInt() ??
          0;
    } else {
      errorMsg = apiResult?['error'] as String? ?? 'Spin failed';
      // Fallback: pick a random discount locally for animation
      final rand = math.Random();
      final r = rand.nextDouble() * 100;
      if (r < 30) {
        discountPct = 5;
      } else if (r < 70) {
        discountPct = 10;
      } else if (r < 85) {
        discountPct = 20;
      } else if (r < 95) {
        discountPct = 25;
      } else {
        discountPct = 30;
      }
    }

    // Calculate the final resting angle for the winning segment
    final targetAngle = _calculateLandingAngle(discountPct);
    final finalAngle = suspenseTarget + targetAngle - (suspenseTarget % (2 * math.pi));

    _rotationAnimation = Tween<double>(
      begin: suspenseTarget,
      end: finalAngle,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller
      ..reset()
      ..forward();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _currentAngle = finalAngle % (2 * math.pi);
        _isSpinning = false;
        _hasResult = true;
        _spinResult = apiResult;
        _errorMsg = errorMsg;
      });
    }
  }

  /// Returns the angle offset needed so the winning segment sits under the pointer (top)
  double _calculateLandingAngle(int discountPct) {
    double startAngle = 0.0;
    for (final seg in _segments) {
      if (seg.discount == discountPct) {
        // Center of this segment should be at the pointer (top = 0, i.e. -π/2 from painter's 0)
        final center = startAngle + seg.sweepAngle / 2;
        // We need (center + landingOffset) % 2π = 0  → landingOffset = -center
        return (2 * math.pi) - center;
      }
      startAngle += seg.sweepAngle;
    }
    return 0;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 320,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3D2B9E), Color(0xFF6B35C8)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              '🎰 Spin & Win!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Costs 100 XP per spin',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),

            // Wheel + pointer
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Drop shadow ring
                  Container(
                    width: 236,
                    height: 236,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Rotating wheel
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, _) {
                      final angle = _isSpinning
                          ? _rotationAnimation.value
                          : _currentAngle;
                      return Transform.rotate(
                        angle: angle,
                        child: CustomPaint(
                          size: const Size(230, 230),
                          painter: _WheelPainter(segments: _segments),
                        ),
                      );
                    },
                  ),
                  // Center hub
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isSpinning ? 0.45 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          'SPIN',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF3D2B9E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pointer triangle at top
                  Positioned(
                    top: 0,
                    child: CustomPaint(
                      size: const Size(24, 28),
                      painter: _PointerPainter(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Result card or spin button
            if (_hasResult)
              _buildResultCard()
            else
              _buildSpinButton(),

            const SizedBox(height: 12),

            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSpinButton() {
    return GestureDetector(
      onTap: _isSpinning ? null : _spin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isSpinning
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isSpinning
              ? []
              : [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            _isSpinning ? 'Spinning...' : '🎯  Spin Now!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _isSpinning
                  ? Colors.white.withValues(alpha: 0.6)
                  : const Color(0xFF3D2B9E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final coupon = _spinResult?['coupon'] as Map<String, dynamic>?;
    final discountPct = (coupon?['discountPct'] as num?)?.toInt() ??
        (_spinResult?['discountPct'] as num?)?.toInt() ??
        0;

    if (_errorMsg != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            const Text('😅', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _spin,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2B9E),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            'You Won!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$discountPct% Discount',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Coupon added to your account!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'Awesome! 🙌',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2B9E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wheel Painter ──────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<_WheelSegment> segments;

  const _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.18; // hole for hub

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final sweep = seg.sweepAngle;

      // Fill slice
      final fillPaint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, fillPaint);

      // Stroke between segments
      final strokePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, strokePaint);

      // Label — draw discount text in the middle of each slice
      final mid = startAngle + sweep / 2;
      final labelRadius = radius * 0.65;
      final lx = center.dx + labelRadius * math.cos(mid);
      final ly = center.dy + labelRadius * math.sin(mid);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${seg.discount}%',
          style: TextStyle(
            fontSize: radius * 0.13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(lx, ly);
      canvas.rotate(mid + math.pi / 2);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      startAngle += sweep;
    }

    // Inner circle (hub cutout background — actual hub widget is drawn on top)
    final hubPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, hubPaint);

    // Outer ring border
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 1, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}

// ─── Pointer Triangle ───────────────────────────────────────────────────────

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // tip pointing down (into wheel)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    // Drop shadow
    canvas.drawShadow(path, Colors.black45, 4, true);
    canvas.drawPath(path, paint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter old) => false;
}
