import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brainup/ui/bottomnavigation.dart';

/// Standalone search results page.
/// Receives the search query and a list of course results from the caller.
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.query,
    required this.results,
  });

  final String query;
  final List<Map<String, dynamic>> results;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // ─── Palette ──────────────────────────────────────────────────────────────
  static const Color _bgColor = Color(0xFFF5F3FF);
  static const Color _primaryPurple = Color(0xFF5E4AB3);
  static const Color _lightPurple = Color(0xFFEDE9FF);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textGray = Color(0xFF9C9AA5);

  // Filter tabs
  static const List<String> _filterLabels = [
    'All',
    'Free',
    'Beginner',
    'Advanced',
    'Pro',
  ];
  int _activeFilter = 0;

  List<Map<String, dynamic>> get _filteredResults {
    if (_activeFilter == 0) return widget.results;

    if (_activeFilter == 1) {
      // Free
      return widget.results.where((c) {
        final isFree = c['isFree'] as bool? ?? false;
        final price = (c['price'] as num?)?.toDouble() ?? 0;
        return isFree || price == 0;
      }).toList();
    }

    // Beginner / Advanced / Pro — filter by difficulty
    final level = _filterLabels[_activeFilter].toLowerCase();
    return widget.results.where((c) {
      final diff = (c['difficulty'] as String?)?.toLowerCase() ?? '';
      return diff == level;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResults;

    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar (read-only, tapping goes back) ──
            _buildSearchHeader(),
            const SizedBox(height: 4),

            // ── Filter tabs ──
            _buildFilterTabs(),
            const SizedBox(height: 12),

            // ── Results grid ──
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          CourseResultCard(course: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Header ──────────────────────────────────────────────────────
  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/Search.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        _primaryPurple,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.query,
                        style: const TextStyle(
                          fontSize: 15,
                          color: _textDark,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter icon button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primaryPurple.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.tune_rounded,
                color: _primaryPurple,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Tabs ────────────────────────────────────────────────────────
  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final isActive = _activeFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? _primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _primaryPurple : const Color(0xFFE0DCF0),
                  width: 1.5,
                ),
              ),
              child: Text(
                _filterLabels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : _textGray,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: _lightPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 44,
              color: _primaryPurple.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No courses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or adjust filters',
            style: TextStyle(fontSize: 14, color: _textGray),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Course Result Card (Grid-friendly, public so search_page can also use it)
// ═══════════════════════════════════════════════════════════════════════════════

class CourseResultCard extends StatelessWidget {
  const CourseResultCard({super.key, required this.course});

  final Map<String, dynamic> course;

  String _formatPrice(dynamic price, bool isFree) {
    if (isFree) return 'FREE';
    final p = (price as num?)?.toDouble() ?? 0;
    if (p == 0) return 'FREE';
    final formatted = p
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final title = course['title'] as String? ?? 'Course Name';
    final thumbnail = course['thumbnail'] as String?;
    final isFree = course['isFree'] as bool? ?? false;
    final price = course['price'];
    final trainer = course['trainer'] as Map<String, dynamic>?;
    final trainerName = trainer?['name'] as String? ?? 'Trainer';
    final isPriceFree = isFree || (price as num?)?.toDouble() == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E4AB3).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to course detail
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: thumbnail != null && thumbnail.isNotEmpty
                        ? Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1B2E),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainerName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9C9AA5),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        _formatPrice(price, isFree),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPriceFree
                              ? const Color(0xFF5E4AB3)
                              : const Color(0xFF5E4AB3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF7B67CC),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: Colors.white54,
          size: 36,
        ),
      ),
    );
  }
}
