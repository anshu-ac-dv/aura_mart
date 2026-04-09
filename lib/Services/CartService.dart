import 'package:flutter/material.dart';

class CartService {
  static final List<Map<String, dynamic>> cartItems = [];
  static String? selectedPaymentMethod;
  static String? selectedPaymentMethodId;

  static void addToCart(Map<String, dynamic> product) {
    final index = cartItems.indexWhere((item) => item['name'] == product['name']);
    
    if (index >= 0) {
      cartItems[index]['qty']++;
    } else {
      dynamic priceVal = product['price'] ?? 0.0;
      double price = 0.0;
      if (priceVal is String) {
        String priceStr = priceVal.replaceAll('\$', '').replaceAll(',', '');
        price = double.tryParse(priceStr) ?? 0.0;
      } else if (priceVal is num) {
        price = priceVal.toDouble();
      }
      
      cartItems.add({
        'name': product['name'] ?? 'Unknown Product',
        'price': price,
        'image': product['image'] ?? '',
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

  static List<Map<String, dynamic>> getSerializableItems() {
    return cartItems.map((item) {
      return {
        'name': item['name'],
        'price': item['price'],
        'qty': item['qty'],
      };
    }).toList();
  }

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

  static double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      total += (item['price'] as double) * (item['qty'] as int);
    }
    return total;
  }
}
