import 'dart:async';
import 'package:eloria_collection/screens/home_screen.dart';
import 'package:eloria_collection/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _letterSpacing;
  late Animation<double> _subtitleFade;
  late Animation<double> _linePadding;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    
    // Main entrance sequence
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Continuous pulse for background
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _letterSpacing = Tween<double>(begin: 40.0, end: 20.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutQuart)),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 0.9, curve: Curves.easeIn)),
    );

    _linePadding = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeInOut)),
    );

    _glowOpacity = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _checkUserStatus();
  }

  void _checkUserStatus() {
    final user = FirebaseAuth.instance.currentUser;
    Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1500),
            pageBuilder: (context, a1, a2) => user != null ? const HomeScreen() : const LoginScreen(),
            transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Dynamic Background Glows
              _buildAmbientGlow(isDarkMode, -150, -100, 400 * _pulseController.value),
              _buildAmbientGlow(isDarkMode, 150, 200, 300 * (1 - _pulseController.value)),
              
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Logo: ELORIA
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Text(
                          'ELORIA',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w200,
                            letterSpacing: _letterSpacing.value,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Animated Decorative Line
                    Container(
                      width: 240,
                      height: 1.5,
                      padding: EdgeInsets.symmetric(horizontal: _linePadding.value),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              primaryColor.withOpacity(0.5),
                              primaryColor,
                              primaryColor.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subtitle: COLLECTION
                    Opacity(
                      opacity: _subtitleFade.value,
                      child: Text(
                        'COLLECTION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Slogan
              Positioned(
                bottom: 80,
                child: Opacity(
                  opacity: _subtitleFade.value * 0.5,
                  child: Column(
                    children: [
                      Text(
                        'REDEFINING COMMERCE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Subtle Loading Bar
                      Container(
                        width: 120,
                        height: 2,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 120 * _mainController.value,
                            height: 2,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAmbientGlow(bool isDarkMode, double x, double y, double size) {
    return Positioned(
      left: x + (MediaQuery.of(context).size.width / 2) - (size / 2),
      top: y + (MediaQuery.of(context).size.height / 2) - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.deepPurple.withOpacity(isDarkMode ? 0.15 : 0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
