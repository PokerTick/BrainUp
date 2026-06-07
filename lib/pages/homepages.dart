import 'package:flutter/material.dart';
import '../ui/bottomnavigation.dart';
import 'my_courses_page.dart';
import '../ui/home_header.dart';
import '../ui/category_section.dart';
import '../ui/course_section.dart';
import '../ui/spinwheel_dialog.dart';

class Homepages extends StatefulWidget {
  const Homepages({super.key});

  @override
  State<Homepages> createState() => _HomepagesState();
}

class _HomepagesState extends State<Homepages> {
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
        body: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              CategorySection(),
              CourseSection(),
              SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 0),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const SpinwheelDialog(),
            );
          },
          backgroundColor: const Color(0xFF6B58E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.sports_esports, // Game controller icon
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
