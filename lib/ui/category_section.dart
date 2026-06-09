import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../pages/search_page.dart';

// Icon + color mapping berdasarkan nama kategori dari API
const _categoryMeta = {
  'technology': (Icons.computer_rounded, Color(0xFF6B58E6)),
  'tech': (Icons.computer_rounded, Color(0xFF6B58E6)),
  'math': (Icons.calculate_rounded, Color(0xFF4A44F2)),
  'mathematics': (Icons.calculate_rounded, Color(0xFF4A44F2)),
  'science': (Icons.science_rounded, Color(0xFF29BF18)),
  'physics': (Icons.bolt_rounded, Color(0xFFF59E0B)),
  'chemistry': (Icons.colorize_rounded, Color(0xFFEF4444)),
  'biology': (Icons.eco_rounded, Color(0xFF10B981)),
  'programming': (Icons.code_rounded, Color(0xFF6B58E6)),
  'design': (Icons.brush_rounded, Color(0xFFEC4899)),
  'business': (Icons.business_center_rounded, Color(0xFF0EA5E9)),
  'language': (Icons.language_rounded, Color(0xFFFF6B35)),
  'music': (Icons.music_note_rounded, Color(0xFF8B5CF6)),
  'art': (Icons.palette_rounded, Color(0xFFEC4899)),
  'history': (Icons.history_edu_rounded, Color(0xFF78716C)),
  'health': (Icons.favorite_rounded, Color(0xFFEF4444)),
};

(IconData, Color) _metaFor(String name) {
  final key = name.toLowerCase().trim();
  for (final entry in _categoryMeta.entries) {
    if (key.contains(entry.key)) return entry.value;
  }
  return (Icons.school_rounded, const Color(0xFF7B42F6));
}

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await ApiService.getCategories();
    if (mounted) {
      setState(() {
        _categories = data;
        _isLoading = false;
      });
    }
  }

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
              _SeeMoreButton(onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(openFilterOnLoad: true),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Category cards
          _isLoading
              ? _buildSkeletonRow()
              : _categories.isEmpty
                  ? _buildEmpty()
                  : _buildCategoryRow(),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    // Show up to 3 categories
    final display = _categories.take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: display.map((cat) {
        final name = cat['name'] as String? ?? 'Category';
        final courseCount = cat['_count']?['courses'] as int? ??
            cat['courseCount'] as int? ??
            0;
        return _CategoryCard(
          name: name,
          courseCount: courseCount,
        );
      }).toList(),
    );
  }

  Widget _buildSkeletonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
        (_) => _SkeletonCard(),
      ),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'No categories found',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 60) / 3;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 48,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.name, required this.courseCount});

  final String name;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _metaFor(name);

    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
              color: color.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            courseCount > 0 ? '$courseCount Course${courseCount != 1 ? 's' : ''}' : '–',
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
