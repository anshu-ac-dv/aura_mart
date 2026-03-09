import 'package:aura_mart/Splash%20Services/Splash_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized before calling asynchronous code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the root widget of the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aura Mart',
      
      // Theme settings to support Light and Dark modes automatically based on system settings
      themeMode: ThemeMode.system, 
      
      // Light Theme Configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      
      // Dark Theme Configuration
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      // Initial screen to show when the app starts
      home: const SplashScreen(),
    );
  }
}
