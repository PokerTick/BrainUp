import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:brainup/ui/bottomnavigation.dart';
import 'package:brainup/services/api_service.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

class EnrolledCourse {
  final int id;
  final String title;
  final String? thumbnailUrl;
  final int progress; // 0-100
  final bool completed;
  final String? trainerName;
  final String? categoryName;

  const EnrolledCourse({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.progress,
    required this.completed,
    this.trainerName,
    this.categoryName,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};
    final trainer = course['trainer'] as Map<String, dynamic>?;
    final category = course['category'] as Map<String, dynamic>?;
    return EnrolledCourse(
      id: course['id'] as int? ?? 0,
      title: course['title'] as String? ?? '',
      thumbnailUrl: course['thumbnailUrl'] as String?,
      progress: json['progress'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      trainerName: trainer?['name'] as String?,
      categoryName: category?['name'] as String?,
    );
  }
}



// ─── Page ────────────────────────────────────────────────────────────────────

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<EnrolledCourse> _allCourses = [];
  List<EnrolledCourse> _filteredCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final raw = await ApiService.getMyCourses();
    final courses = raw.map((e) => EnrolledCourse.fromJson(e)).toList();
    if (mounted) {
      setState(() {
        _allCourses = courses;
        _filteredCourses = courses;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _allCourses
          .where((c) => c.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Search Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD6C9F5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9C84D4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2B2B2F),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'What do you want to learn?',
                          hintStyle: TextStyle(
                            color: Color(0xFF9C84D4),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF5E4AB3),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Course List ──────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5E4AB3),
                      ),
                    )
                  : _filteredCourses.isEmpty
                      ? _buildEmptyState()
                      : _buildCourseList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _filteredCourses.length + 1, // +1 for "that's all ~"
      itemBuilder: (context, index) {
        if (index < _filteredCourses.length) {
          final course = _filteredCourses[index];
          final isFirst = index == 0;
          final isLast = index == _filteredCourses.length - 1;
          return _CourseCard(
            course: course,
            isFirst: isFirst,
            isLast: isLast,
          );
        }
        // "that's all ~" footer
        return const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 8),
          child: Center(
            child: Text(
              "that's all ~",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFB0A0D0),
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: const Color(0xFF5E4AB3).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No courses found',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB0A0D0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Course Card ─────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final EnrolledCourse course;
  final bool isFirst;
  final bool isLast;

  const _CourseCard({
    required this.course,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
      topRight: isFirst ? const Radius.circular(16) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Thumbnail placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E0F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: course.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            course.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _ThumbnailPlaceholder(),
                          ),
                        )
                      : const _ThumbnailPlaceholder(),
                ),

                const SizedBox(width: 14),

                // Title
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2B2F),
                      height: 1.35,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Circular progress indicator
                _CircularProgress(progress: course.progress),
              ],
            ),
          ),

          // Divider (not shown for last item)
          if (!isLast)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFF0EBF8),
            ),
        ],
      ),
    );
  }
}

// ─── Thumbnail Placeholder ────────────────────────────────────────────────────

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDDD4F0),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ─── Circular Progress ────────────────────────────────────────────────────────

class _CircularProgress extends StatelessWidget {
  final int progress; // 0–100

  const _CircularProgress({required this.progress});

  Color _progressColor(int pct) {
    if (pct >= 100) return const Color(0xFF5E4AB3); // purple – complete
    if (pct >= 60) return const Color(0xFF4A44F2);  // blue
    if (pct >= 40) return const Color(0xFFB5E048);  // yellow-green
    return const Color(0xFFE84D8A);                 // pink
  }

  @override
  Widget build(BuildContext context) {
    final color = _progressColor(progress);
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(52, 52),
            painter: _RingPainter(
              progress: progress / 100.0,
              progressColor: color,
              trackColor: const Color(0xFFE8E0F5),
              strokeWidth: 5.5,
            ),
          ),
          Text(
            '$progress%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B2F),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}
