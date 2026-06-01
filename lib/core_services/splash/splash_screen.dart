import 'dart:async';
import 'package:aura_mart/screens/home_screen.dart';
import 'package:aura_mart/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );

    _checkUserStatus();
  }

  void _checkUserStatus() {
    final user = FirebaseAuth.instance.currentUser;
    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1200),
            pageBuilder: (context, a1, a2) => user != null ? const HomeScreen() : const LoginScreen(),
            transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF050505) : const Color(0xFFFDFDFD),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background "Aura"
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 300 * _pulseAnimation.value,
                height: 300 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                        ? Colors.deepPurple.withAlpha(40) 
                        : Colors.deepPurple.withAlpha(20),
                      blurRadius: 100,
                      spreadRadius: 50,
                    )
                  ],
                  gradient: RadialGradient(
                    colors: [
                      Colors.deepPurple.withAlpha(isDarkMode ? 80 : 30),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  'AURA',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 25,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 200,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      isDarkMode ? Colors.white30 : Colors.black12,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'MART',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  color: isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple,
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 60,
            child: Text(
              'REDEFINING COMMERCE',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 5,
                color: isDarkMode ? Colors.white24 : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
