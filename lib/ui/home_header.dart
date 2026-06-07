import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Greeting row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Takeshi!',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(65, 66, 227, 1),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Good to see you again',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // EXP Index
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department, // Or star, depending on what EXP represents
                        color: Color(0xFFFFD700), // Gold
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '1,240 XP',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromARGB(255, 41, 191, 24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/Takeshi.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Streak card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Streak count row
                  Row(
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '69',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF7B42F6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Days!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2D3A),
                        ),
                      ),
                      const Spacer(),
                      // Weekly day indicators
                      ..._buildDayIndicators(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // "Keep Going!" + Day labels
                  Row(
                    children: [
                      Text(
                        'Keep Going!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7B42F6),
                        ),
                      ),
                      const Spacer(),
                      ..._buildDayLabels(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDayIndicators() {
    final days = [
      {'done': true},
      {'done': true},
      {'done': false},
      {'done': false},
      {'done': false},
    ];

    List<Widget> widgets = [];
    for (int i = 0; i < days.length; i++) {
      final isDone = days[i]['done'] as bool;
      widgets.add(
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? const Color(0xFF7B42F6) : Colors.grey.shade200,
            border: Border.all(
              color: isDone ? const Color(0xFF7B42F6) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      );

      // Add connecting line
      if (i < days.length - 1) {
        final nextIsDone = days[i + 1]['done'] as bool;
        widgets.add(
          Container(
            width: 8,
            height: 3,
            color: isDone && nextIsDone
                ? const Color(0xFF7B42F6)
                : Colors.grey.shade300,
          ),
        );
      }
    }
    return widgets;
  }

  List<Widget> _buildDayLabels() {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    List<Widget> widgets = [];
    
    for (int i = 0; i < labels.length; i++) {
      widgets.add(
        SizedBox(
          width: 28,
          child: Text(
            labels[i],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );

      // Add spacer to match the connecting line width
      if (i < labels.length - 1) {
        widgets.add(const SizedBox(width: 8));
      }
    }
    return widgets;
  }
}
