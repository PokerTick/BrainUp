import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/api_service.dart';
import '../../services/recent_search_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ─── Palette ──────────────────────────────────────────────────────────────
  static const Color _bgColor = Color(0xFFF5F3FF);
  static const Color _primaryPurple = Color(0xFF5E4AB3);
  static const Color _lightPurple = Color(0xFFEDE9FF);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textGray = Color(0xFF9C9AA5);
  static const Color _divider = Color(0xFFEBE8F5);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoading = true;
  bool _isSearching = false;

  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  bool _hasSearched = false;
  int _totalResults = 0;

  // Active filters
  int? _selectedCategoryId;
  bool? _isFree; // null = all, true = free, false = paid
  double _minPrice = 0;
  double _maxPrice = _kMaxPrice;
  static const double _kMaxPrice = 1000000;

  bool get _hasActiveFilters => _selectedCategoryId != null || _isFree != null;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  Future<void> _loadRecentSearches() async {
    final list = await RecentSearchService.getRecentSearches();
    if (mounted) setState(() => _recentSearches = list);
  }

  Future<void> _loadCategories() async {
    setState(() => _categoriesLoading = true);
    final cats = await ApiService.getCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _categoriesLoading = false;
      });
    }
  }

  Future<void> _submitSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _focusNode.unfocus();
    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    await RecentSearchService.addSearch(trimmed);
    await _loadRecentSearches();

    final result = await ApiService.searchCourses(
      trimmed,
      categoryId: _selectedCategoryId,
      isFree: _isFree,
      minPrice: (_isFree == true || _minPrice == 0) ? null : _minPrice,
      maxPrice: (_isFree == true || _maxPrice >= _kMaxPrice) ? null : _maxPrice,
    );

    if (mounted) {
      final courses =
          (result['courses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final total = result['total'] as int? ?? 0;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _searchResults = courses;
        _totalResults = total;
      });
    }
  }

  Future<void> _removeRecent(String query) async {
    await RecentSearchService.removeSearch(query);
    await _loadRecentSearches();
  }

  Future<void> _clearAll() async {
    await RecentSearchService.clearAll();
    await _loadRecentSearches();
  }

  void _onRecentTap(String query) {
    _searchController.text = query;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));
    _submitSearch(query);
  }

  void _onCategoryTap(Map<String, dynamic> cat) {
    final name = cat['name'] ?? '';
    _searchController.text = name;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: name.length));
    _submitSearch(name);
  }

  void _removeFilter({bool removeCategory = false, bool removeIsFree = false}) {
    setState(() {
      if (removeCategory) _selectedCategoryId = null;
      if (removeIsFree) _isFree = null;
    });
    if (_searchController.text.trim().isNotEmpty) {
      _submitSearch(_searchController.text.trim());
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(
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
          if (_searchController.text.trim().isNotEmpty) {
            _submitSearch(_searchController.text.trim());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_hasActiveFilters) _buildActiveFilterBar(),
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryPurple),
                    )
                  : _hasSearched
                      ? _buildResultsView()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_recentSearches.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildRecentSearchSection(),
                                const SizedBox(height: 24),
                                Divider(color: _divider, thickness: 1),
                                const SizedBox(height: 24),
                              ],
                              _buildTrendingSection(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                onSubmitted: _submitSearch,
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
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: _textGray, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _hasSearched = false;
                              _searchResults = [];
                            });
                            _focusNode.requestFocus();
                          },
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _hasActiveFilters ? _primaryPurple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withValues(
                          alpha: _hasActiveFilters ? 0.3 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _showFilterSheet,
                    child: Center(
                      child: Icon(
                        Icons.tune_rounded,
                        color:
                            _hasActiveFilters ? Colors.white : _primaryPurple,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E5E),
                      shape: BoxShape.circle,
                      border: Border.all(color: _bgColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search Results ───────────────────────────────────────────────────────
  Widget _buildResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Text(
                '$_totalResults course${_totalResults != 1 ? 's' : ''} found',
                style: const TextStyle(
                  fontSize: 13,
                  color: _textGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasSearched = false;
                    _searchResults = [];
                  });
                  _searchController.clear();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 13,
                    color: _primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: _searchResults.length,
                  itemBuilder: (_, i) =>
                      _CourseResultCard(course: _searchResults[i]),
                ),
        ),
      ],
    );
  }

  // ─── Recent Searches ─────────────────────────────────────────────────────
  Widget _buildRecentSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            GestureDetector(
              onTap: _clearAll,
              child: const Text(
                'Clear',
                style: TextStyle(
                  fontSize: 13,
                  color: _textGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_recentSearches.length, (i) {
          final q = _recentSearches[i];
          return _RecentSearchItem(
            query: q,
            onTap: () => _onRecentTap(q),
            onRemove: () => _removeRecent(q),
          );
        }),
      ],
    );
  }

  // ─── Trending Topics ──────────────────────────────────────────────────────
  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Topic',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 16),
        if (_categoriesLoading)
          ...List.generate(4, (_) => const _TrendingItemSkeleton())
        else if (_categories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No topics available',
                style: TextStyle(color: _textGray, fontSize: 14),
              ),
            ),
          )
        else
          ...List.generate(_categories.length, (i) {
            final cat = _categories[i];
            return _TrendingItem(
              category: cat,
              onTap: () => _onCategoryTap(cat),
            );
          }),
      ],
    );
  }
}

// ─── Filter Bottom Sheet ───────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.categories,
    required this.initialCategoryId,
    required this.initialIsFree,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.maxPriceLimit,
    required this.onApply,
  });

  final List<Map<String, dynamic>> categories;
  final int? initialCategoryId;
  final bool? initialIsFree;
  final double initialMinPrice;
  final double initialMaxPrice;
  final double maxPriceLimit;
  final void Function(
      int? categoryId, bool? isFree, double minPrice, double maxPrice) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const Color _purple = Color(0xFF5E4AB3);
  static const Color _lightPurple = Color(0xFFEDE9FF);
  static const Color _bgChip = Color(0xFFF5F3FF);
  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textGray = Color(0xFF9C9AA5);
  static const Color _chipBorder = Color(0xFFE0DCF0);

  late int? _categoryId;
  late bool? _isFree;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _isFree = widget.initialIsFree;
    _priceRange = RangeValues(widget.initialMinPrice, widget.initialMaxPrice);
  }

  void _reset() {
    setState(() {
      _categoryId = null;
      _isFree = null;
      _priceRange = RangeValues(0, widget.maxPriceLimit);
    });
  }

  String _formatPriceLabel(double price) {
    if (price >= 1000000) {
      return 'Rp${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)}jt';
    }
    if (price >= 1000) {
      return 'Rp${(price / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp${price.toInt()}';
  }

  int get _activeFilterCount =>
      (_categoryId != null ? 1 : 0) + (_isFree != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DCF0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _reset,
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: const Color(0xFFEBE8F5), thickness: 1),
          ),
          const SizedBox(height: 4),
          // ── Scrollable content ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category section
                  _sectionLabel('Category'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCategoryChip(null, 'All'),
                      ...widget.categories.map(
                        (c) => _buildCategoryChip(
                          c['id'] as int?,
                          c['name'] as String? ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Course type section
                  _sectionLabel('Course Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypeChip(null, 'All'),
                      const SizedBox(width: 10),
                      _buildTypeChip(true, '🎁  Free'),
                      const SizedBox(width: 10),
                      _buildTypeChip(false, '💰  Paid'),
                    ],
                  ),

                  // Price range — only when Paid selected
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    child: _isFree == false
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _sectionLabel('Price Range'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _lightPurple,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_formatPriceLabel(_priceRange.start)} – ${_formatPriceLabel(_priceRange.end)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _purple,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: _purple,
                                  inactiveTrackColor: _lightPurple,
                                  thumbColor: _purple,
                                  overlayColor:
                                      _purple.withValues(alpha: 0.12),
                                  trackHeight: 4,
                                ),
                                child: RangeSlider(
                                  values: _priceRange,
                                  min: 0,
                                  max: widget.maxPriceLimit,
                                  divisions: 100,
                                  onChanged: (vals) =>
                                      setState(() => _priceRange = vals),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatPriceLabel(0),
                                      style: const TextStyle(
                                          fontSize: 11, color: _textGray)),
                                  Text(
                                      _formatPriceLabel(widget.maxPriceLimit),
                                      style: const TextStyle(
                                          fontSize: 11, color: _textGray)),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // ── Apply button ──
          Padding(
            padding:
                EdgeInsets.fromLTRB(24, 8, 24, bottomPad > 0 ? bottomPad : 24),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => widget.onApply(
                  _categoryId,
                  _isFree,
                  _priceRange.start,
                  _priceRange.end,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Apply Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_activeFilterCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_activeFilterCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _textDark,
      ),
    );
  }

  Widget _buildCategoryChip(int? id, String label) {
    final selected = _categoryId == id;
    return GestureDetector(
      onTap: () => setState(() => _categoryId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _purple : _bgChip,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _purple : _chipBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(bool? value, String label) {
    final selected = _isFree == value;
    return GestureDetector(
      onTap: () => setState(() => _isFree = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purple : _bgChip,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _purple : _chipBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _textGray,
          ),
        ),
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

// ─── Course Result Card ────────────────────────────────────────────────────
class _CourseResultCard extends StatelessWidget {
  const _CourseResultCard({required this.course});

  final Map<String, dynamic> course;

  String _formatPrice(dynamic price, bool isFree) {
    if (isFree) return 'Free';
    final p = (price as num?)?.toDouble() ?? 0;
    if (p == 0) return 'Free';
    // Format as Indonesian Rupiah
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
    final title = course['title'] as String? ?? '';
    final thumbnail = course['thumbnail'] as String?;
    final isFree = course['isFree'] as bool? ?? false;
    final price = course['price'];
    final category = course['category'] as Map<String, dynamic>?;
    final trainer = course['trainer'] as Map<String, dynamic>?;
    final avgRating =
        (course['averageRating'] as num?)?.toDouble() ?? 0.0;
    final count = course['_count'] as Map<String, dynamic>?;
    final enrollCount = (count?['enrollments'] as int?) ?? 0;
    final isPriceFree = isFree || (price as num?)?.toDouble() == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E4AB3).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Navigate to course detail
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: thumbnail != null && thumbnail.isNotEmpty
                      ? Image.network(
                          thumbnail,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null)
                        Text(
                          category['name'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B67CC),
                            letterSpacing: 0.3,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1B2E),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (trainer != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          trainer['name'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9C9AA5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Rating
                          if (avgRating > 0) ...[
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFC107), size: 14),
                            const SizedBox(width: 2),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1B2E),
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9C9AA5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          // Enrollments
                          const Icon(Icons.people_rounded,
                              size: 13, color: Color(0xFF9C9AA5)),
                          const SizedBox(width: 3),
                          Text(
                            '$enrollCount',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF9C9AA5)),
                          ),
                          const Spacer(),
                          // Price badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPriceFree
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFEDE9FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatPrice(price, isFree),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isPriceFree
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF5E4AB3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 82,
      height: 82,
      color: const Color(0xFFEDE9FF),
      child: const Icon(
        Icons.play_circle_outline_rounded,
        color: Color(0xFF7B67CC),
        size: 34,
      ),
    );
  }
}

// ─── Recent Search Item ────────────────────────────────────────────────────
class _RecentSearchItem extends StatelessWidget {
  const _RecentSearchItem({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const Color _textDark = Color(0xFF1E1B2E);
  static const Color _textGray = Color(0xFF9C9AA5);
  static const Color _iconPurple = Color(0xFF7B67CC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Icon(Icons.history_rounded, color: _iconPurple, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  query,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textDark,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.cancel_outlined,
                  color: _textGray,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Trending Item ─────────────────────────────────────────────────────────
class _TrendingItem extends StatelessWidget {
  const _TrendingItem({required this.category, required this.onTap});

  final Map<String, dynamic> category;
  final VoidCallback onTap;

  static const Color _lightPurple = Color(0xFFEDE9FF);
  static const Color _iconPurple = Color(0xFF7B67CC);
  static const Color _textDark = Color(0xFF1E1B2E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.public_rounded,
                        color: _iconPurple, size: 26),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _iconPurple.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton loader for trending items ───────────────────────────────────
class _TrendingItemSkeleton extends StatefulWidget {
  const _TrendingItemSkeleton();

  @override
  State<_TrendingItemSkeleton> createState() => _TrendingItemSkeletonState();
}

class _TrendingItemSkeletonState extends State<_TrendingItemSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) {
          final shimmer = Color.lerp(
              const Color(0xFFEDE9FF), const Color(0xFFD8D0F5), _anim.value)!;
          return Container(
            height: 76,
            decoration: BoxDecoration(
              color: shimmer,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
