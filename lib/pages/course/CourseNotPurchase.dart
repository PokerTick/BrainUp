import 'package:brainup/pages/course/CoursePurchase.dart';
import 'package:brainup/services/api_service.dart';
import 'package:brainup/ui/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Coursenotpurchase extends StatefulWidget {
  final int courseId;
  const Coursenotpurchase({super.key, required this.courseId});

  @override
  State<Coursenotpurchase> createState() => _CoursenotpurchaseState();
}

class _CoursenotpurchaseState extends State<Coursenotpurchase> {
  bool isBookmarked = false;
  Map<String, dynamic>? courseData;
  bool isLoading = true;
  bool isEnrolling = false;

  @override
  void initState() {
    super.initState();
    _fetchCourse();
  }

  Future<void> _fetchCourse() async {
    final data = await ApiService.getCourseById(widget.courseId);
    if (mounted) {
      setState(() {
        courseData = data;
        isLoading = false;
      });
    }
  }

  Future<void> _enrollCourse() async {
    setState(() => isEnrolling = true);
    final success = await ApiService.enrollInCourse(widget.courseId);
    if (mounted) {
      setState(() => isEnrolling = false);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Coursepurchase(courseId: widget.courseId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enroll in the course. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B58E6)))
          : courseData == null
              ? const Center(child: Text('Course not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero Image Section ──
                      _buildHeroImage(context),

                      // ── Course Info Body ──
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
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + Bookmark
                                _buildTitleRow(),
                                const SizedBox(height: 16),

                                // Instructor + Category Tag
                                _buildInstructorRow(),
                                const SizedBox(height: 24),

                                // Price + Buy Button
                                _buildPriceSection(),
                                const SizedBox(height: 20),

                                // Published & Enrolled Stats
                                _buildStatsCard(),
                                const SizedBox(height: 24),

                                // Description
                                _buildDescriptionSection(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const _CourseBottomNavBar(),
    );
  }

  /// Hero image with back button overlay
  Widget _buildHeroImage(BuildContext context) {
    final thumbnailUrl = courseData?['thumbnailUrl'] ?? courseData?['thumbnail'];
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Course image
          if (thumbnailUrl != null && thumbnailUrl.toString().isNotEmpty)
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'lib/assets/Coding.png',
                fit: BoxFit.cover,
              ),
            )
          else
            Image.asset(
              'lib/assets/Coding.png',
              fit: BoxFit.cover,
            ),
          // Gradient overlay for readability
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
          // Back button
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

  /// Course title with bookmark icon
  Widget _buildTitleRow() {
    final title = courseData?['title'] ?? 'Untitled Course';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              isBookmarked = !isBookmarked;
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              key: ValueKey(isBookmarked),
              color: const Color(0xFF6B58E6),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  /// Instructor avatar, name, and category tag
  Widget _buildInstructorRow() {
    final trainer = courseData?['trainer'] as Map<String, dynamic>?;
    final trainerName = trainer?['name'] ?? 'Unknown Trainer';
    final trainerAvatar = trainer?['avatar'];
    
    final category = courseData?['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] ?? 'Uncategorized';

    return Row(
      children: [
        // Instructor avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6B58E6).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: trainerAvatar != null
                ? Image.network(
                    trainerAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'lib/assets/Takeshi.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'lib/assets/Takeshi.png',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        // Instructor name
        Text(
          trainerName,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3A3A4A),
          ),
        ),
        const SizedBox(width: 12),
        // Category tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6B58E6).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            categoryName,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B58E6),
            ),
          ),
        ),
      ],
    );
  }

  /// Total price label + Buy Course button
  Widget _buildPriceSection() {
    final price = courseData?['price'];
    final isFree = courseData?['isFree'] == true;
    
    String priceDisplay = 'Free';
    if (!isFree && price != null) {
      final priceNum = (price as num).toDouble();
      if (priceNum > 0) {
        priceDisplay = 'Rp${priceNum.toStringAsFixed(0)}';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Price',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8A9A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              priceDisplay,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Buy Course button
        ElevatedButton(
          onPressed: isEnrolling ? null : _enrollCourse,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B58E6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF6B58E6).withValues(alpha: 0.35),
          ),
          child: isEnrolling 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : Text(
              'Buy Course',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
        ),
      ],
    );
  }

  /// Published and Enrolled stats in a soft card
  Widget _buildStatsCard() {
    final createdAtStr = courseData?['createdAt'];
    String publishedDate = 'Unknown';
    if (createdAtStr != null && createdAtStr.length >= 10) {
      publishedDate = createdAtStr.substring(0, 10);
    }

    final enrollments = courseData?['enrollments'] as List?;
    final enrolledCount = enrollments?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B58E6).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Published stat
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B58E6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF6B58E6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Published',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        publishedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A8A9A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFF6B58E6).withValues(alpha: 0.15),
          ),
          const SizedBox(width: 16),
          // Enrolled stat
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B58E6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Color(0xFF6B58E6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enrolled',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      '$enrolledCount Peoples',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8A9A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Course description section
  Widget _buildDescriptionSection() {
    final description = courseData?['description'] ?? 'No description available.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF5A5A6A),
            height: 1.65,
          ),
        ),
      ],
    );
  }
}

// ── Bottom Navigation Bar (matching the design) ──
class _CourseBottomNavBar extends StatelessWidget {
  const _CourseBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return const AppBottomNavigationBar(initialIndex: 2);
  }
}