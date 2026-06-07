import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../ui/bottomnavigation.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

class _Student {
  final String name;
  final String subtitle;
  final int progress; // 0-100
  final Color avatarColor;

  const _Student({
    required this.name,
    required this.subtitle,
    required this.progress,
    required this.avatarColor,
  });
}

// ─── Page ────────────────────────────────────────────────────────────────────

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();

  static const _tabs = ['Active', 'Completed', 'Recent'];

  static const _students = [
    _Student(
      name: 'Sarah Jenkins',
      subtitle: 'React Fundamentals',
      progress: 84,
      avatarColor: Color(0xFFFFB6D9),
    ),
    _Student(
      name: 'Marcus Chen',
      subtitle: 'JavaScript Advanced',
      progress: 42,
      avatarColor: Color(0xFF82B1FF),
    ),
    _Student(
      name: 'Elena Rodriguez',
      subtitle: 'SQL for Beginners',
      progress: 12,
      avatarColor: Color(0xFFA5D6A7),
    ),
    _Student(
      name: 'David Wilson',
      subtitle: 'React Fundamentals',
      progress: 96,
      avatarColor: Color(0xFFFFCC80),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildFilterTabs(),
                  const SizedBox(height: 20),
                  _buildEnrolledCount(),
                  const SizedBox(height: 16),
                  ..._students.map((s) => _buildStudentCard(s)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7A5CFF), Color(0xFF9B82FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'lib/assets/BackgroundLogSign.svg',
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 24, 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'Student Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFB6D9), width: 2),
                        image: const DecorationImage(
                          image: AssetImage('lib/assets/Takeshi.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A5CFF).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students or courses...',
          hintStyle: const TextStyle(
            color: Color(0xFFB0AEBF),
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF7A5CFF), size: 22),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final isActive = index == _selectedTab;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF7A5CFF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF7A5CFF)
                      : const Color(0xFFE8E6F0),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF9C9AA5),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEnrolledCount() {
    return Text(
      'Enrolled Students (${_students.length * 31})',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1B2E),
      ),
    );
  }

  Widget _buildStudentCard(_Student student) {
    final progressColor = student.progress >= 80
        ? const Color(0xFF4CAF50)
        : student.progress >= 40
            ? const Color(0xFFFFA726)
            : const Color(0xFFEF5350);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A5CFF).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: student.avatarColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.name[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: student.avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9C9AA5),
                  ),
                ),
              ],
            ),
          ),
          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${student.progress}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
