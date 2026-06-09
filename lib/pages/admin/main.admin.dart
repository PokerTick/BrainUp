import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_login_page.dart';
import 'admin_shell.dart';

void main() {
  // This is the entrypoint for the Flutter Web Admin Panel
  // Run with: flutter run -d chrome -t lib/pages/admin/main.admin.dart
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainUp Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B58E6)),
        fontFamily: 'Poppins',
      ),
      home: const _AdminSplashRouter(),
    );
  }
}

class _AdminSplashRouter extends StatefulWidget {
  const _AdminSplashRouter();

  @override
  State<_AdminSplashRouter> createState() => _AdminSplashRouterState();
}

class _AdminSplashRouterState extends State<_AdminSplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService.getAccessToken();
    if (!mounted) return;

    Widget destination = const AdminLoginPage();

    if (token != null) {
      final profile = await ApiService.getUserProfile();
      final role = profile?['role']?.toString().toUpperCase();
      if (role == 'ADMIN') {
        destination = const AdminShell();
      } else {
        // If logged in but not admin, clear token for safety on admin panel
        await ApiService.clearTokens();
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9F9FB),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF6B58E6)),
      ),
    );
  }
}
