import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_login_page.dart';
import 'admin_dashboard_page.dart';
import 'user_management_page.dart';
import 'trainer_requests_page.dart';
import 'course_management_page.dart';
import 'order_management_page.dart';
import 'category_management_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const UserManagementPage(),
    const TrainerRequestsPage(),
    const CourseManagementPage(),
    const OrderManagementPage(),
    const CategoryManagementPage(),
  ];

  Future<void> _handleLogout() async {
    await ApiService.clearTokens();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.school_rounded, color: Color(0xFF6B58E6), size: 32),
                      SizedBox(width: 12),
                      Text(
                        'BrainUp Admin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B2B2F),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
                      _buildNavItem(1, Icons.people_outline, 'Users'),
                      _buildNavItem(2, Icons.how_to_reg_outlined, 'Trainer Requests'),
                      _buildNavItem(3, Icons.menu_book_outlined, 'Courses'),
                      _buildNavItem(4, Icons.receipt_long_outlined, 'Orders'),
                      _buildNavItem(5, Icons.category_outlined, 'Categories'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  onTap: _handleLogout,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF6B58E6) : const Color(0xFF9C9AA5),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF6B58E6) : const Color(0xFF9C9AA5),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFF0EDFF),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
