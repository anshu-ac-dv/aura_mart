import 'dart:async';
import 'package:aura_mart/Screens/HomeScreen.dart';
import 'package:aura_mart/Screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for the fade-in and scale effect
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Check if the user is already logged in or not
    _checkUserStatus();
  }

  void _checkUserStatus() {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    // Timer to keep the splash screen visible for a few seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        if (user != null) {
          // If user is logged in, navigate to Home Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // If no user is logged in, navigate to Login Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Gradient background for a modern look
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Animated App Name
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'AURA MART',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Your Premium Shopping Destination',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 50),
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
