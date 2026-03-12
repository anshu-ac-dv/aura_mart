import 'package:aura_mart/Screens/Products/Categories/CategoryBaseScreen.dart';
import 'package:flutter/material.dart';

class ElectronicsScreen extends StatelessWidget {
  const ElectronicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> products = [
      {'name': 'Aura Laptop Pro', 'price': '\$1299', 'image': 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=1000&auto=format&fit=crop'},
      {'name': 'Ultra Phone 15', 'price': '\$999', 'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=1000&auto=format&fit=crop'},
      {'name': 'SoundMax Buds', 'price': '\$199', 'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop'},
      {'name': 'Smart Pad 12', 'price': '\$799', 'image': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=1000&auto=format&fit=crop'},
    ];

    return CategoryBaseScreen(
      title: "Electronics",
      themeColor: Colors.blue,
      products: products,
    );
  }
}
