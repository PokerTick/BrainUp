import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  int _xp = 0;
  int _currentStreak = 0;
  String _userName = 'there';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    // Fetch both Dashboard and Profile concurrently
    final results = await Future.wait([
      ApiService.getGamificationDashboard(),
      ApiService.getUserProfile(),
    ]);
    
    final dashboardData = results[0];
    final profileData = results[1];

    if (mounted) {
      setState(() {
        _xp = (dashboardData?['xp'] as num?)?.toInt() ?? 0;
        _currentStreak = (dashboardData?['currentStreak'] as num?)?.toInt() ?? 0;
        
        if (profileData != null && profileData['name'] != null) {
          final fullName = profileData['name'] as String;
          // Extract first name for a friendlier greeting
          _userName = fullName.split(' ').first;
        }
        
        _isLoading = false;
      });
    }
  }

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
                        'Hey $_userName! 👋',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      _isLoading
                          ? const SizedBox(
                              width: 40,
                              height: 12,
                              child: LinearProgressIndicator(
                                backgroundColor: Color(0xFFE0E0E0),
                                color: Color(0xFF29BF18),
                              ),
                            )
                          : Text(
                              '${_formatXp(_xp)} XP',
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: _isLoading
                  ? _buildStreakSkeleton()
                  : Column(
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
                              '$_currentStreak',
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
                            ..._buildDayIndicators(_currentStreak),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // "Keep Going!" + Day labels
                        Row(
                          children: [
                            Text(
                              _currentStreak > 0 ? 'Keep Going!' : 'Start Today!',
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

  Widget _buildStreakSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 100,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            Container(
              width: 140,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }

  List<Widget> _buildDayIndicators(int streak) {
    // Show the last 5 days of the week relative to streak
    final doneCount = streak.clamp(0, 5);

    List<Widget> widgets = [];
    for (int i = 0; i < 5; i++) {
      final isDone = i < doneCount;
      widgets.add(
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? const Color(0xFF7B42F6) : Colors.grey.shade200,
            border: Border.all(
              color:
                  isDone ? const Color(0xFF7B42F6) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      );

      if (i < 4) {
        final nextIsDone = (i + 1) < doneCount;
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

      if (i < labels.length - 1) {
        widgets.add(const SizedBox(width: 8));
      }
    }
    return widgets;
  }
}
