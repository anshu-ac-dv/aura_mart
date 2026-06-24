import 'package:aura_mart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_event.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_state.dart';
import 'package:aura_mart/screens/home_screen.dart';
import 'package:aura_mart/widgets/aura_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              _emailController.text.trim(),
              _passwordController.text.trim(),
              _nameController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Fluttertoast.showToast(msg: "Registration Successful");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          Fluttertoast.showToast(msg: state.message);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.deepPurple),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode 
                    ? [Colors.black, Colors.deepPurple.shade900.withAlpha(77)]
                    : [Colors.white, Colors.deepPurple.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Lottie.network(
                        'https://lottie.host/9e4d5f7b-1a9c-46a4-9e32-f2a8c3d8d672/6zV7Y5WpLp.json', // Cute Welcome
                        height: 180,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_add_outlined, size: 80, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Join Aura Mart',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : Colors.deepPurple.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text('Create an account to start shopping', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 40),
                      
                      FadeInAnimation(
                        delay: 400,
                        child: TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your name' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      FadeInAnimation(
                        delay: 500,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      FadeInAnimation(
                        delay: 600,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      FadeInAnimation(
                        delay: 700,
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _register,
                              child: isLoading
                                  ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('REGISTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
