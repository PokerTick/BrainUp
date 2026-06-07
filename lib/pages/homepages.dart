import 'package:flutter/material.dart';
import '../main.dart' show routeObserver;
import '../ui/bottomnavigation.dart';
import '../ui/home_header.dart';
import '../ui/category_section.dart';
import '../ui/course_section.dart';
import '../ui/spinwheel_dialog.dart';

class Homepages extends StatefulWidget {
  const Homepages({super.key});

  @override
  State<Homepages> createState() => _HomepagesState();
}

class _HomepagesState extends State<Homepages> with RouteAware {
  // Changing this key forces all child sections to rebuild & re-fetch
  int _refreshKey = 0;
  bool _isRefreshing = false;

  // ─── RouteAware lifecycle ─────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes (safe to call multiple times)
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when the user pops a child route and comes back to this page
  @override
  void didPopNext() {
    _refresh();
  }

  // ─── Manual refresh (pull-to-refresh) ────────────────────────────────────

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _refreshKey++;
    });
    // A brief pause so RefreshIndicator animation feels natural
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isRefreshing = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 190, 132, 251),
            Color.fromARGB(255, 255, 255, 255),
          ],
          stops: [0.05, 0.40],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF6B58E6),
          backgroundColor: Colors.white,
          displacement: 60,
          child: SingleChildScrollView(
            // Always scrollable so pull-to-refresh works even when content is short
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Keyed so they fully rebuild (and re-fetch) when _refreshKey changes
                HomeHeader(key: ValueKey('header_$_refreshKey')),
                CategorySection(key: ValueKey('cat_$_refreshKey')),
                CourseSection(key: ValueKey('course_$_refreshKey')),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 0),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const SpinwheelDialog(),
            );
          },
          backgroundColor: const Color(0xFF6B58E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.sports_esports,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
