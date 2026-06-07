import 'package:brainup/ui/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WatchVideo extends StatefulWidget {
  const WatchVideo({super.key});

  @override
  State<WatchVideo> createState() => _WatchVideoState();
}

class _WatchVideoState extends State<WatchVideo> {
  int _currentLessonIndex = 0;

  static const _lessons = [
    _LessonData(
      title: 'Part 1: Learning the basics',
      duration: '10:32',
      progress: 0.0,
    ),
    _LessonData(
      title: 'Part 2: Variables & Data Types',
      duration: '12:45',
      progress: 0.0,
    ),
    _LessonData(
      title: 'Part 3: Conditions & Loops',
      duration: '15:20',
      progress: 0.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──
            _buildHeroImage(context),

            // ── Content Body ──
            Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active video player
                      _buildVideoPlayer(context),
                      const SizedBox(height: 16),

                      // Active lesson info row
                      _buildLessonInfoRow(_lessons[_currentLessonIndex]),
                      const SizedBox(height: 24),

                      // Remaining lessons
                      ...List.generate(_lessons.length, (index) {
                        if (index == _currentLessonIndex) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _currentLessonIndex = index);
                            },
                            child: _buildLessonCard(
                                _lessons[index], index, context),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 2),
    );
  }

  /// Hero image with back button
  Widget _buildHeroImage(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/Coding.png',
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Main video player area with play + fullscreen buttons
  Widget _buildVideoPlayer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video thumbnail
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(
                'lib/assets/Coding.png',
                fit: BoxFit.cover,
              ),
            ),
            // Dark overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
            ),
            // Play button
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Play/pause video
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF6B58E6),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            // Fullscreen button (bottom-right)
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () => _openFullscreen(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a fullscreen video overlay
  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenVideoView(
            lessonTitle: _lessons[_currentLessonIndex].title,
            lessonDuration: _lessons[_currentLessonIndex].duration,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Lesson info row (title + duration + progress ring)
  Widget _buildLessonInfoRow(_LessonData lesson) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.duration,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          // Progress ring
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: lesson.progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6B58E6),
                  ),
                ),
                if (lesson.progress > 0)
                  Text(
                    '${(lesson.progress * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B58E6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A smaller lesson card in the list
  Widget _buildLessonCard(
      _LessonData lesson, int index, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(
                'lib/assets/Coding.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF6B58E6),
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.duration,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lesson data model
class _LessonData {
  final String title;
  final String duration;
  final double progress;

  const _LessonData({
    required this.title,
    required this.duration,
    required this.progress,
  });
}

// ═══════════════════════════════════════════════════════
// Fullscreen Video View
// ═══════════════════════════════════════════════════════

class _FullscreenVideoView extends StatefulWidget {
  final String lessonTitle;
  final String lessonDuration;

  const _FullscreenVideoView({
    required this.lessonTitle,
    required this.lessonDuration,
  });

  @override
  State<_FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<_FullscreenVideoView> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Force landscape + hide system UI for true fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore portrait + system UI on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _exitFullscreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video thumbnail / player area
            Center(
              child: Image.asset(
                'lib/assets/Coding.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),

            // Dark overlay when controls visible
            if (_showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),

            // Controls overlay
            if (_showControls) ...[
              // Top bar: back + title
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _exitFullscreen,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.lessonTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Center play/pause
              Positioned.fill(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rewind 10s
                      GestureDetector(
                        onTap: () {
                          // TODO: Rewind
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Play / Pause
                      GestureDetector(
                        onTap: () {
                          // TODO: Play/Pause
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF6B58E6),
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Forward 10s
                      GestureDetector(
                        onTap: () {
                          // TODO: Forward
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom bar: progress + duration + exit fullscreen
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Seek bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF6B58E6),
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.3),
                            thumbColor: const Color(0xFF6B58E6),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 3,
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                          ),
                          child: Slider(
                            value: 0.0,
                            onChanged: (value) {
                              // TODO: Seek
                            },
                          ),
                        ),
                        // Duration + fullscreen exit
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Text(
                                '0:00 / ${widget.lessonDuration}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _exitFullscreen,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen_exit_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
