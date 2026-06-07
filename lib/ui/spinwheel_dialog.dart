import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinwheelDialog extends StatefulWidget {
  const SpinwheelDialog({super.key});

  @override
  State<SpinwheelDialog> createState() => _SpinwheelDialogState();
}

class _SpinwheelDialogState extends State<SpinwheelDialog> {
  bool _isSpinning = false;
  bool _hasWon = false;

  void _spin() {
    setState(() {
      _isSpinning = true;
    });

    // Simulate spinning delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _hasWon = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF6B58E6), // Matching purple from mockup
          borderRadius: BorderRadius.circular(24),
        ),
        child: _hasWon ? _buildWonState() : _buildSpinState(),
      ),
    );
  }

  Widget _buildSpinState() {
    return Column(
      children: [
        // Image Header
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Image.asset(
                'lib/assets/spinwheel.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Spin Button Area
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Spin Button
              GestureDetector(
                onTap: _isSpinning ? null : _spin,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: _isSpinning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6B58E6),
                                ),
                              )
                            : Text(
                                'Spin',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5E4AB3),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              // Empty dark blue box placeholder as in design
              Container(
                width: 70,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF382A85),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWonState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You Won!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          // Discount Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '20% Discount',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5E4AB3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // OK Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D3A),
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
