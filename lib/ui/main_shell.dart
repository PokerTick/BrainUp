import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/homepages.dart';
import '../pages/search_page.dart';

/// Shell widget that owns the bottom navigation and the page stack.
/// Replace the usage of [Homepages] as root with [MainShell].
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _items = [
    _NavItemData(label: 'Home', assetPath: 'lib/assets/Home.svg'),
    _NavItemData(label: 'Search', assetPath: 'lib/assets/Search.svg'),
    _NavItemData(label: 'My Courses', assetPath: 'lib/assets/Course.svg'),
    _NavItemData(label: 'Profile', assetPath: 'lib/assets/Profile.svg'),
  ];

  // Pages keyed so their state is preserved when switching tabs
  final _pages = const [
    _HomeTab(),
    SearchPage(),
    _PlaceholderTab(label: 'My Courses'),
    _PlaceholderTab(label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (i) => setState(() => _currentIndex = i),
        bottomPadding: bottomPadding,
      ),
    );
  }
}

// ─── Home tab wraps the original Homepages content ───────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    // Reuse the homepage body directly (without its own Scaffold so there's no
    // double bottom bar).
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
      child: const SafeArea(
        child: Center(child: Text('Home', style: TextStyle(fontSize: 24))),
      ),
    );
  }
}

// ─── Generic placeholder for tabs not yet implemented ────────────────────
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label,
          style: const TextStyle(fontSize: 24, color: Color(0xFF5E4AB3))),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.bottomPadding,
  });

  final int currentIndex;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 12.0;
        const barHeight = 70.0;
        const floatingSize = 56.0;

        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final itemWidth = availableWidth / items.length;
        final notchCenterX =
            horizontalPadding + (itemWidth * currentIndex) + (itemWidth / 2);

        return SizedBox(
          height: barHeight + (floatingSize / 2) + 4 + bottomPadding,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated white bar background
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight + (floatingSize / 2) + 4 + bottomPadding,
                child: _AnimatedBarBackground(
                  notchCenterX: notchCenterX,
                  barHeight: barHeight,
                  floatingSize: floatingSize,
                ),
              ),
              // Nav items row
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: bottomPadding,
                height: barHeight,
                child: Row(
                  children: List.generate(items.length, (index) {
                    final isActive = index == currentIndex;
                    return Expanded(
                      child: _NavItem(
                        data: items[index],
                        isActive: isActive,
                        onTap: () => onTap(index),
                      ),
                    );
                  }),
                ),
              ),
              // Floating bubble
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: notchCenterX - (floatingSize / 2),
                top: 0,
                child: _FloatingActiveIcon(
                  assetPath: items[currentIndex].assetPath,
                  size: floatingSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Animated bar background (ported from original bottomnavigation.dart) ─
class _AnimatedBarBackground extends StatelessWidget {
  const _AnimatedBarBackground({
    required this.notchCenterX,
    required this.barHeight,
    required this.floatingSize,
  });

  final double notchCenterX;
  final double barHeight;
  final double floatingSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: notchCenterX),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, animatedX, child) {
        return CustomPaint(
          painter: _BottomNavPainter(
            notchCenterX: animatedX,
            barTop: floatingSize / 2 + 4,
            bumpRadius: 38.0,
            bumpHeight: floatingSize / 2 + 4,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BottomNavPainter extends CustomPainter {
  _BottomNavPainter({
    required this.notchCenterX,
    required this.barTop,
    required this.bumpRadius,
    required this.bumpHeight,
  });

  final double notchCenterX;
  final double barTop;
  final double bumpRadius;
  final double bumpHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, barTop);
    path.lineTo(notchCenterX - bumpRadius - 12, barTop);
    path.cubicTo(
      notchCenterX - bumpRadius, barTop,
      notchCenterX - bumpRadius + 8, barTop + bumpHeight,
      notchCenterX, barTop + bumpHeight,
    );
    path.cubicTo(
      notchCenterX + bumpRadius - 8, barTop + bumpHeight,
      notchCenterX + bumpRadius, barTop,
      notchCenterX + bumpRadius + 12, barTop,
    );
    path.lineTo(size.width, barTop);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.15), 8.0, false);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomNavPainter oldDelegate) =>
      oldDelegate.notchCenterX != notchCenterX;
}

class _NavItemData {
  const _NavItemData({required this.label, required this.assetPath});
  final String label;
  final String assetPath;
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.data, required this.isActive, required this.onTap});

  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeTextColor = Color(0xFF2B2B2F);
    const inactiveTextColor = Color(0xFF9C9AA5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isActive ? 0.0 : 0.3,
            child: SvgPicture.asset(data.assetPath, width: 24, height: 24),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeTextColor : inactiveTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingActiveIcon extends StatelessWidget {
  const _FloatingActiveIcon({required this.assetPath, required this.size});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(assetPath, width: 26, height: 26),
      ),
    );
  }
}
