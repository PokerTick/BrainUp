import 'package:brainup/pages/course/CoursePurchase/Forum.dart';
import 'package:brainup/pages/course/CoursePurchase/WatchVideo.dart';
import 'package:brainup/services/api_service.dart';
import 'package:brainup/ui/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Coursepurchase extends StatefulWidget {
  final int courseId;
  const Coursepurchase({super.key, required this.courseId});

  @override
  State<Coursepurchase> createState() => _CoursepurchaseState();
}

class _CoursepurchaseState extends State<Coursepurchase> {
  bool isDescriptionExpanded = true;
  Map<String, dynamic>? courseData;
  bool isLoading = true;

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
                                // Title
                                _buildTitle(),
                                const SizedBox(height: 16),

                                // Instructor + Category Tag
                                _buildInstructorRow(),
                                const SizedBox(height: 20),

                                // Published & Enrolled Stats
                                _buildStatsCard(),
                                const SizedBox(height: 24),

                                // Description (expandable)
                                _buildDescriptionHeader(),
                                if (isDescriptionExpanded) ...[
                                  const SizedBox(height: 10),
                                  _buildDescriptionBody(),
                                ],
                                const SizedBox(height: 24),

                                // Video lesson card
                                _buildVideoLessonCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      // Chat FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Forum()),
          );
        },
        backgroundColor: const Color(0xFF6B58E6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 2),
    );
  }

  /// Hero image with back button overlay
  Widget _buildHeroImage(BuildContext context) {
    final thumbnailUrl = courseData?['thumbnailUrl'] ?? courseData?['thumbnail'];
    return SizedBox(
      height: 280,
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
          // Gradient overlay
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

  /// Course title
  Widget _buildTitle() {
    final title = courseData?['title'] ?? 'Untitled Course';
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
        height: 1.3,
      ),
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

  /// Published and Enrolled stats card
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

  /// "Description ∨" expandable header
  Widget _buildDescriptionHeader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isDescriptionExpanded = !isDescriptionExpanded;
        });
      },
      child: Row(
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedRotation(
            turns: isDescriptionExpanded ? 0.0 : -0.25,
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF1A1A2E),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Description body text (shown when expanded)
  Widget _buildDescriptionBody() {
    final description = courseData?['description'] ?? 'No description available.';
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Text(
        description,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF5A5A6A),
          height: 1.65,
        ),
      ),
    );
  }

  /// Video lesson card with play overlay
  Widget _buildVideoLessonCard() {
    final title = courseData?['title'] ?? 'Learning the basics';
    final thumbnailUrl = courseData?['thumbnailUrl'] ?? courseData?['thumbnail'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WatchVideo()),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                child: (thumbnailUrl != null && thumbnailUrl.toString().isNotEmpty)
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'lib/assets/Coding.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'lib/assets/Coding.png',
                        fit: BoxFit.cover,
                      ),
              ),
              // Dark gradient overlay
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
              // Play button center
              Positioned.fill(
                child: Center(
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
              // Bottom info: title + duration
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Preview',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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
      ),
    );
  }
}