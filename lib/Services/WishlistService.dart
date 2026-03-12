import 'package:flutter/material.dart';

class WishlistService {
  // Static list to store wishlist items across the app
  static final List<Map<String, String>> wishlistItems = [];

  // Logic to add or remove item
  static bool toggleWishlist(Map<String, String> product) {
    final index = wishlistItems.indexWhere((item) => item['name'] == product['name']);
    if (index >= 0) {
      wishlistItems.removeAt(index);
      return false; // Removed
    } else {
      wishlistItems.add(product);
      return true; // Added
    }
  }

  static bool isInWishlist(Map<String, String> product) {
    return wishlistItems.any((item) => item['name'] == product['name']);
  }
}
