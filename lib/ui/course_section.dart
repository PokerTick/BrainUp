import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseSection extends StatelessWidget {
  const CourseSection({super.key});

  static const _courses = [
    _CourseData(
      name: 'Course Name',
      trainer: 'Course Trainer',
      rating: 'Rating disini',
      price: 'harga disini',
      imagePath: 'lib/assets/course_1.png',
      bgColor: Color.fromARGB(255, 255, 255, 255),
    ),
    _CourseData(
      name: 'Course Name',
      trainer: 'Course Trainer',
      rating: 'Rating disini',
      price: 'harga disini',
      imagePath: 'lib/assets/course_2.png',
      bgColor: Color.fromARGB(255, 255, 255, 255),
    ),
  ];

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
              _SeeMoreButton(onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
          // Course cards grid (2 columns)
          Row(
            children: _courses.map((course) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: course == _courses.first ? 6 : 0,
                    left: course == _courses.last ? 6 : 0,
                  ),
                  child: _CourseCard(data: course),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CourseData {
  const _CourseData({
    required this.name,
    required this.trainer,
    required this.rating,
    required this.price,
    required this.imagePath,
    required this.bgColor,
  });

  final String name;
  final String trainer;
  final String rating;
  final String price;
  final String imagePath;
  final Color bgColor;
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.data});

  final _CourseData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.bgColor,
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
          // Course image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 1.3,
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Course info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D3A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.trainer,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.rating,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.price,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
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
