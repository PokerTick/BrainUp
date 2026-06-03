import 'package:brainup/pages/Login&Signup/login.dart';
import 'package:flutter/material.dart';
import '../ui/bottomnavigation.dart';
import 'Login&Signup/singup.dart';

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
          stops: [0.05, 0.40]
        ),
      ),
      child: Scaffold(
        body:Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Singup()),
                  );
              }, child: const Text("Singup")),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Login()),
                  );
                  }, child: const Text("Login")),
                ],
            ),
          ),
        
        backgroundColor: Colors.transparent,
        bottomNavigationBar: AppBottomNavigationBar(),
      ),
    );
  }
}