import 'dart:async';
import 'package:aura_mart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_state.dart';
import 'package:aura_mart/screens/home_screen.dart';
import 'package:aura_mart/screens/login_screen.dart';
import 'package:aura_mart/widgets/aura_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => authState is Authenticated ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: FadeInAnimation(
          delay: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleInAnimation(
                delay: 500,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 60,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Aura Mart',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Quality at your doorstep',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(200),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
