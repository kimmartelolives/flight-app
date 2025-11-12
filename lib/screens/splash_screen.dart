
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:elective3project/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080), // Navy Blue
      body: Center(
        child: Image.asset(
          'assets/images/open.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          // Optional: Add an error builder for debugging
          errorBuilder: (context, error, stackTrace) {
            // This will show a red broken image icon if the asset fails to load
            return const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.red,
                size: 100,
              ),
            );
          },
        ),
      ),
    );
  }
}
