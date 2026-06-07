import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  static const _categories = [
    _CategoryData(
      name: 'Technology',
      courseCount: '100 Course',
      imagePath: 'lib/assets/category_tech.png',
    ),
    _CategoryData(
      name: 'Math',
      courseCount: '100 Course',
      imagePath: 'lib/assets/category_math.png',
    ),
    _CategoryData(
      name: 'Science',
      courseCount: '100 Course',
      imagePath: 'lib/assets/category_science.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Category',
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
          // Category cards row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _categories.map((cat) {
              return _CategoryCard(data: cat);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.name,
    required this.courseCount,
    required this.imagePath,
  });

  final String name;
  final String courseCount;
  final String imagePath;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B42F6).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.courseCount,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
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
