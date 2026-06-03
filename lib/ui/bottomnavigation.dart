import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({super.key});

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  int currentIndex = 0;

  static const _items = [
    _NavItemData(label: 'Home', assetPath: 'lib/assets/Home.svg'),
    _NavItemData(label: 'Search', assetPath: 'lib/assets/Search.svg'),
    _NavItemData(label: 'My Courses', assetPath: 'lib/assets/Course.svg'),
    _NavItemData(label: 'Profile', assetPath: 'lib/assets/Profile.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 12.0;
        const barHeight = 70.0;
        const floatingSize = 56.0;

        final availableWidth =
            constraints.maxWidth - (horizontalPadding * 2);
        final itemWidth = availableWidth / _items.length;
        final notchCenterX = horizontalPadding +
            (itemWidth * currentIndex) +
            (itemWidth / 2);

        return SizedBox(
          height: barHeight + (floatingSize / 2) + 4 + bottomPadding,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // White bar background with upward bump
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight + (floatingSize / 2) + 4 + bottomPadding,
                child: AnimatedBuilder(
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
                  children: List.generate(_items.length, (index) {
                    final isActive = index == currentIndex;
                    return Expanded(
                      child: _NavItem(
                        data: _items[index],
                        isActive: isActive,
                        onTap: () =>
                            setState(() => currentIndex = index),
                      ),
                    );
                  }),
                ),
              ),
              // Floating bubble circle for active icon
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: notchCenterX - (floatingSize / 2),
                top: 0,
                child: _FloatingActiveIcon(
                  assetPath: _items[currentIndex].assetPath,
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

/// Animated background painter that draws the white bar with a smooth upward bump
class AnimatedBuilder extends StatelessWidget {
  const AnimatedBuilder({
    super.key,
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

    // Start from top-left of the bar area
    path.moveTo(0, barTop);

    // Line to just before the bump/notch
    path.lineTo(notchCenterX - bumpRadius - 12, barTop);

    // Smooth cubic bezier curve going DOWN for the notch
    path.cubicTo(
      notchCenterX - bumpRadius, barTop,
      notchCenterX - bumpRadius + 8, barTop + bumpHeight, // Changed - to +
      notchCenterX, barTop + bumpHeight, // Changed - to +
    );

    // Mirror curve going back UP
    path.cubicTo(
      notchCenterX + bumpRadius - 8, barTop + bumpHeight, // Changed - to +
      notchCenterX + bumpRadius, barTop,
      notchCenterX + bumpRadius + 12, barTop,
    );

    // Continue to right edge
    path.lineTo(size.width, barTop);

    // Close the bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.15),
      8.0,
      false,
    );

    // Fill white
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomNavPainter oldDelegate) {
    return oldDelegate.notchCenterX != notchCenterX;
  }
}

class _NavItemData {
  const _NavItemData({required this.label, required this.assetPath});

  final String label;
  final String assetPath;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

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
          // Icon — invisible when active (the floating bubble shows it instead)
          Opacity(
            opacity: isActive ? 0.0 : 0.3,
            child: SvgPicture.asset(
              data.assetPath,
              width: 24,
              height: 24,
            ),
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
  const _FloatingActiveIcon({
    super.key,
    required this.assetPath,
    required this.size,
  });

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF5E4AB3);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        // border: Border.all(
        //   color: borderColor.withOpacity(0.25),
        //   width: 2,
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          width: 26,
          height: 26,
        ),
      ),
    );
  }
}
