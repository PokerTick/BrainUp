import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brainup/ui/bottomnavigation.dart';
import 'package:brainup/services/api_service.dart';
import 'package:brainup/pages/course/CoursePurchase.dart';
import 'package:brainup/pages/search_page.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

class EnrolledCourse {
  final int id;
  final String title;
  final String? thumbnailUrl;
  final int progress; // 0-100
  final bool completed;
  final String? trainerName;
  final String? categoryName;
  final int? categoryId;
  final double price;

  const EnrolledCourse({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.progress,
    required this.completed,
    this.trainerName,
    this.categoryName,
    this.categoryId,
    this.price = 0.0,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};
    final trainer = course['trainer'] as Map<String, dynamic>?;
    final category = course['category'] as Map<String, dynamic>?;
    
    // Attempt to parse price
    double parsedPrice = 0.0;
    if (course['price'] != null) {
      parsedPrice = (course['price'] as num).toDouble();
    }

    return EnrolledCourse(
      id: course['id'] as int? ?? 0,
      title: course['title'] as String? ?? '',
      thumbnailUrl: course['thumbnailUrl'] as String?,
      progress: json['progress'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      trainerName: trainer?['name'] as String?,
      categoryName: category?['name'] as String?,
      categoryId: category?['id'] as int?,
      price: parsedPrice,
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
  final FocusNode _focusNode = FocusNode();

  List<EnrolledCourse> _allCourses = [];
  List<EnrolledCourse> _filteredCourses = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  // Filter state
  int? _selectedCategoryId;
  bool? _isFree;
  double _minPrice = 0;
  double _maxPrice = _kMaxPrice;
  static const double _kMaxPrice = 1000000;

  bool get _hasActiveFilters => _selectedCategoryId != null || _isFree != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final futures = await Future.wait([
      ApiService.getMyCourses(),
      ApiService.getCategories(),
    ]);

    final rawCourses = futures[0] as List<dynamic>;
    final cats = futures[1] as List<Map<String, dynamic>>;

    final courses = rawCourses.map((e) => EnrolledCourse.fromJson(e)).toList();
    if (mounted) {
      setState(() {
        _allCourses = courses;
        _categories = cats;
        _filteredCourses = courses;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _onSearchChanged() => _applyFilters();

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredCourses = _allCourses.where((c) {
        // Text search
        if (query.isNotEmpty && !c.title.toLowerCase().contains(query)) {
          return false;
        }
        // Category
        if (_selectedCategoryId != null && c.categoryId != _selectedCategoryId) {
          return false;
        }
        // Price/Free
        if (_isFree != null) {
          final isCourseFree = c.price <= 0;
          if (_isFree! != isCourseFree) return false;
        }
        // Price range
        if (c.price < _minPrice || c.price > _maxPrice) return false;

        return true;
      }).toList();
    });
  }

  void _removeFilter({bool removeCategory = false, bool removeIsFree = false}) {
    setState(() {
      if (removeCategory) _selectedCategoryId = null;
      if (removeIsFree) _isFree = null;
    });
    _applyFilters();
  }

  void _showFilterSheet() {
    // Import CourseFilterSheet from search_page.dart (since we'll import it at the top)
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => CourseFilterSheet(
        categories: _categories,
        initialCategoryId: _selectedCategoryId,
        initialIsFree: _isFree,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        maxPriceLimit: _kMaxPrice,
        onApply: (catId, isFree, minP, maxP) {
          setState(() {
            _selectedCategoryId = catId;
            _isFree = isFree;
            _minPrice = minP;
            _maxPrice = maxP;
          });
          Navigator.pop(ctx);
          _applyFilters();
        },
      ),
    );
  }

  // ─── Palette ──────────────────────────────────────────────────────────────
  static const Color _bgColor = Color(0xFFF5F3FF);
  static const Color _primaryPurple = Color(0xFF5E4AB3);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textGray = Color(0xFF9C9AA5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _buildSearchBar(),
            if (_hasActiveFilters) _buildActiveFilterBar(),

            const SizedBox(height: 16),

            // ── Course List ──────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _primaryPurple,
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

  // ─── Active filter chips bar ──────────────────────────────────────────────
  Widget _buildActiveFilterBar() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (_selectedCategoryId != null)
                  _ActiveChip(
                    label: _categories
                            .where((c) => c['id'] == _selectedCategoryId)
                            .map((c) => c['name'] as String)
                            .firstOrNull ??
                        'Category',
                    onRemove: () =>
                        _removeFilter(removeCategory: true),
                  ),
                if (_isFree != null)
                  _ActiveChip(
                    label: _isFree! ? '🎁 Free' : '💰 Paid',
                    onRemove: () => _removeFilter(removeIsFree: true),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onSubmitted: (_) => _focusNode.unfocus(),
                style: const TextStyle(
                  fontSize: 15,
                  color: _textDark,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'What do you want to learn?',
                  hintStyle: TextStyle(
                    color: _textGray.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'lib/assets/Search.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _searchController.text.isNotEmpty
                            ? _primaryPurple
                            : _textGray,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                            _focusNode.requestFocus();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(Icons.close_rounded,
                                color: _textGray, size: 20),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button with active indicator
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _hasActiveFilters ? _primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: _hasActiveFilters
                    ? null
                    : Border.all(
                        color: const Color(0xFFEBE8F5),
                        width: 1.5,
                      ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: _hasActiveFilters ? Colors.white : _primaryPurple,
                    size: 24,
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B), // Amber dot
                          shape: BoxShape.circle,
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

// ─── Active Filter Chip ────────────────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: const Color(0xFF5E4AB3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5E4AB3).withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5E4AB3),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: Color(0xFF5E4AB3),
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Coursepurchase(courseId: course.id),
          ),
        );
      },
      child: Container(
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
