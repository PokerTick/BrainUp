import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brainup/ui/bottomnavigation.dart';
import '../services/api_service.dart';
import 'search_page.dart';

/// Standalone search results page.
/// Receives the search query and a list of course results from the caller.
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.query,
    required this.results,
    required this.categories,
    this.initialCategoryId,
    this.initialIsFree,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.maxPriceLimit,
  });

  final String query;
  final List<Map<String, dynamic>> results;
  final List<Map<String, dynamic>> categories;
  final int? initialCategoryId;
  final bool? initialIsFree;
  final double initialMinPrice;
  final double initialMaxPrice;
  final double maxPriceLimit;

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
  
  late List<Map<String, dynamic>> _currentResults;
  bool _isSearching = false;
  
  // Advanced filters from sheet
  late int? _selectedCategoryId;
  late bool? _isFree;
  late double _minPrice;
  late double _maxPrice;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentResults = widget.results;
    _selectedCategoryId = widget.initialCategoryId;
    _isFree = widget.initialIsFree;
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    
    _searchController.text = widget.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredResults {
    if (_activeFilter == 0) return _currentResults;

    if (_activeFilter == 1) {
      // Free
      return _currentResults.where((c) {
        final isFree = c['isFree'] as bool? ?? false;
        final price = (c['price'] as num?)?.toDouble() ?? 0;
        return isFree || price == 0;
      }).toList();
    }

    // Beginner / Advanced / Pro — filter by difficulty
    final level = _filterLabels[_activeFilter].toLowerCase();
    return _currentResults.where((c) {
      final diff = (c['difficulty'] as String?)?.toLowerCase() ?? '';
      return diff == level;
    }).toList();
  }

  Future<void> _fetchNewResults() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    _focusNode.unfocus();
    setState(() => _isSearching = true);
    final result = await ApiService.searchCourses(
      query,
      limit: 20,
      categoryId: _selectedCategoryId,
      isFree: _isFree,
      minPrice: (_isFree == true || _minPrice == 0) ? null : _minPrice,
      maxPrice: (_isFree == true || _maxPrice >= widget.maxPriceLimit)
          ? null
          : _maxPrice,
    );

    List<Map<String, dynamic>> courses = [];
    final inner = result['courses'] ?? result['data'] ?? result;
    if (inner is List) {
      courses = inner.cast<Map<String, dynamic>>();
    }

    if (mounted) {
      setState(() {
        _currentResults = courses;
        _isSearching = false;
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => CourseFilterSheet(
        categories: widget.categories,
        initialCategoryId: _selectedCategoryId,
        initialIsFree: _isFree,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        maxPriceLimit: widget.maxPriceLimit,
        onApply: (catId, isFree, minP, maxP) {
          setState(() {
            _selectedCategoryId = catId;
            _isFree = isFree;
            _minPrice = minP;
            _maxPrice = maxP;
          });
          Navigator.pop(ctx);
          _fetchNewResults();
        },
      ),
    );
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
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryPurple),
                    )
                  : filtered.isEmpty
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
              child: Row(
                children: [
                  // Back Button inside the search bar on the left
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: _textGray,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _fetchNewResults(),
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
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _searchController.clear();
                          _focusNode.requestFocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Icon(Icons.close_rounded,
                              color: _textGray, size: 20),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter icon button
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              shadowColor: _primaryPurple.withValues(alpha: 0.08),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _showFilterSheet();
                },
                child: const Center(
                  child: Icon(
                    Icons.tune_rounded,
                    color: _primaryPurple,
                    size: 22,
                  ),
                ),
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
          return Material(
            color: isActive ? _primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _activeFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
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
