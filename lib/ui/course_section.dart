import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../pages/course/CourseNotPurchase.dart';
import '../pages/search_results_page.dart';

class CourseSection extends StatefulWidget {
  const CourseSection({super.key});

  @override
  State<CourseSection> createState() => _CourseSectionState();
}

class _CourseSectionState extends State<CourseSection> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final data = await ApiService.getCourses(limit: 4);
    if (mounted) {
      setState(() {
        _courses = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse for more',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D3A),
                ),
              ),
              _SeeMoreButton(
                onTap: () async {
                  // Fetch more courses when 'See More' is pressed to show all
                  final allCourses = await ApiService.getCourses(limit: 100);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsPage(
                          query: '',
                          results: allCourses,
                          categories: const [],
                          initialMinPrice: 0.0,
                          initialMaxPrice: 1000000.0,
                          maxPriceLimit: 1000000.0,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Course grid
          _isLoading
              ? _buildSkeletonGrid()
              : _courses.isEmpty
              ? _buildEmpty()
              : _buildCourseGrid(),
        ],
      ),
    );
  }

  Widget _buildCourseGrid() {
    // Show up to 4 courses in a 2-column grid
    final display = _courses.take(4).toList();

    if (display.isEmpty) return _buildEmpty();

    // Pair into rows of 2
    final List<Widget> rows = [];
    for (int i = 0; i < display.length; i += 2) {
      final left = display[i];
      final right = i + 1 < display.length ? display[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < display.length ? 12 : 0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _CourseCard(data: left),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: right != null
                      ? _CourseCard(data: right)
                      : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildSkeletonGrid() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SkeletonCard(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: _SkeletonCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'No courses available',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8E0F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Untitled';
    final trainer = data['trainer'] as Map<String, dynamic>?;
    final trainerName = trainer?['name'] as String? ?? 'Unknown Trainer';
    final thumbnailUrl = data['thumbnailUrl'] as String?;
    final price = data['price'];
    final isFree = data['isFree'] as bool? ?? false;

    String priceDisplay;
    if (isFree) {
      priceDisplay = 'Free';
    } else if (price != null) {
      final priceNum = (price as num).toDouble();
      if (priceNum == 0) {
        priceDisplay = 'Free';
      } else {
        priceDisplay = 'Rp ${_formatPrice(priceNum)}';
      }
    } else {
      priceDisplay = 'Free';
    }

    final avgRating = data['avgRating'] ?? data['averageRating'];
    final ratingDisplay = avgRating != null
        ? '⭐ ${(avgRating as num).toStringAsFixed(1)}'
        : '⭐ –';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Coursenotpurchase(courseId: data['id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 1.3,
                child: thumbnailUrl != null
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            // Course info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D3A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trainerName,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ratingDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isFree || (price as num? ?? 0) == 0
                          ? const Color(0xFF29BF18).withValues(alpha: 0.1)
                          : const Color(0xFF7B42F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priceDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isFree || (price as num? ?? 0) == 0
                            ? const Color(0xFF29BF18)
                            : const Color(0xFF7B42F6),
                      ),
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

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFE8E0F5),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: Color(0xFF7B42F6),
          size: 32,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}rb';
    }
    return price.toStringAsFixed(0);
  }
}

class _SeeMoreButton extends StatelessWidget {
  const _SeeMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF7B42F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'See More >',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
