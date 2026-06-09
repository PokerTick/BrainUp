import 'package:brainup/pages/Login&Signup/login.dart';
import 'package:brainup/pages/homepages.dart';
import 'package:brainup/pages/trainer_dashboard.dart';
import 'package:brainup/services/api_service.dart';
import 'package:flutter/material.dart';

/// Global route observer — widgets can subscribe to know when their route
/// becomes active again (e.g., user presses Back from a child route).
final routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainUp',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B58E6)),
        fontFamily: 'Poppins',
      ),
      home: const _SplashRouter(),
    );
  }
}

/// Checks if a token exists in SharedPreferences.
/// If yes → go straight to Homepages.
/// If no  → go to Login.
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService.getAccessToken();
    if (!mounted) return;

    Widget destination = const Login();

    if (token != null) {
      final profile = await ApiService.getUserProfile();
      final role = profile?['role'] as String?;
      if (role?.toUpperCase() == 'TRAINER') {
        destination = const TrainerDashboard();
      } else {
        destination = const Homepages();
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
    // Brief splash while we check — purple gradient + logo feel
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B58E6), Color(0xFF3D2B9E)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 72, color: Colors.white),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
