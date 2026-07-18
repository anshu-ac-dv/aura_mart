import 'package:aura_mart/core_services/splash/splash_screen.dart';
import 'package:aura_mart/core_services/theme_service.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_event.dart';
import 'package:aura_mart/features/auth/presentation/bloc/auth_state.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_event.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_bloc.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

  // Initialize persistent theme
  await ThemeService.instance.init();

  // Enable offline persistence for Firestore with platform-specific handling
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => di.sl<CartBloc>()..add(CartStarted()),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => di.sl<ProductBloc>()..add(ProductsFetched()),
        ),
        BlocProvider<OrderBloc>(create: (context) => di.sl<OrderBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated || state is Unauthenticated) {
            context.read<CartBloc>().add(CartStarted());
          }
        },
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.instance.themeMode,
          builder: (context, mode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Aura Mart',
              themeMode: mode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  primary: Colors.indigo,
                  secondary: Colors.blueGrey,
                  brightness: Brightness.light,
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: ZoomPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  primary: Colors.indigo,
                  brightness: Brightness.dark,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                ),
              ),
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
