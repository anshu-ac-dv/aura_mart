import 'package:aura_mart/screens/products/categories/aura_category_base_screen.dart';
import 'package:flutter/material.dart';

class ElectronicsScreen extends StatelessWidget {
  const ElectronicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> products = [
      {'name': 'Aura StudioBook', 'price': '\$1499', 'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1000&auto=format&fit=crop'},
      {'name': 'X-Phone Ultra', 'price': '\$1099', 'image': 'https://images.unsplash.com/photo-1592890288564-76628a30a657?q=80&w=1000&auto=format&fit=crop'},
      {'name': 'Sonic Pods Gen 3', 'price': '\$249', 'image': 'https://images.unsplash.com/photo-1588423770574-d109ad10d42d?q=80&w=1000&auto=format&fit=crop'},
      {'name': 'Tab-Z Infinity', 'price': '\$899', 'image': 'https://images.unsplash.com/photo-1510784722466-f2aa9c52dee6?q=80&w=1000&auto=format&fit=crop'},
    ];

    return CategoryBaseScreen(
      title: "Electronics",
      themeColor: Colors.blue,
      products: products,
    );
  }
}
