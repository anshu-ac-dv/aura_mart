import 'package:flutter/material.dart';

class CartService {
  // Static list to store cart items globally
  static final List<Map<String, dynamic>> cartItems = [];

  // Logic to add product to cart
  static void addToCart(Map<String, String> product) {
    // Check if item already exists in cart
    final index = cartItems.indexWhere((item) => item['name'] == product['name']);
    
    if (index >= 0) {
      // Increase quantity if already exists
      cartItems[index]['qty']++;
    } else {
      // Add new item with quantity 1
      String priceStr = product['price'] ?? '0';
      priceStr = priceStr.replaceAll('\$', '').replaceAll(',', '');
      
      cartItems.add({
        'name': product['name'] ?? 'Unknown Product',
        'price': double.tryParse(priceStr) ?? 0.0,
        'icon': _getIconForCategory(product['category'] ?? ''),
        'qty': 1,
      });
    }
  }

  static void incrementQty(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index]['qty']++;
    }
  }

  static void decrementQty(int index) {
    if (index >= 0 && index < cartItems.length) {
      if (cartItems[index]['qty'] > 1) {
        cartItems[index]['qty']--;
      } else {
        cartItems.removeAt(index);
      }
    }
  }

  static void removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  static void clearCart() {
    cartItems.clear();
  }

  // Helper to map category to icon
  static IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Electronics': return Icons.bolt_rounded;
      case 'Fashion': return Icons.checkroom_rounded;
      case 'Home': return Icons.home_rounded;
      case 'Toys': return Icons.smart_toy_rounded;
      case 'Beauty': return Icons.face_retouching_natural_rounded;
      case 'Sports': return Icons.sports_tennis_rounded;
      case 'Accessories': return Icons.watch_rounded;
      case 'Books': return Icons.auto_stories_rounded;
      default: return Icons.shopping_bag_rounded;
    }
  }

  // Calculate total price
  static double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      total += (item['price'] as double) * (item['qty'] as int);
    }
    return total;
  }
}
