import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuraWishlistService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Safely get the user's wishlist collection reference
  static CollectionReference<Map<String, dynamic>>? get _userWishlist {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('wishlist');
  }

  // Unified ID generation to prevent mismatches and invalid characters
  static String generateDocId(String? name) {
    if (name == null || name.isEmpty) return "unknown_product";
    // Replace any non-alphanumeric character with underscore for safe Firestore IDs
    return name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  // Logic: Add or Remove product from Firestore
  static Future<void> toggleWishlist(Map<String, dynamic> product) async {
    try {
      final wishlist = _userWishlist;
      if (wishlist == null) throw Exception("User not logged in");

      final String? name = product['name']?.toString();
      if (name == null) return;

      final docId = generateDocId(name);
      final docRef = wishlist.doc(docId);

      // Attempt to get the document. If offline, Firestore returns cached data.
      // If the server is unreachable and cache is empty, it might throw 'unavailable'.
      DocumentSnapshot doc;
      try {
        doc = await docRef.get(const GetOptions(source: Source.serverAndCache));
      } catch (e) {
        // Fallback to cache if server is unavailable
        doc = await docRef.get(const GetOptions(source: Source.cache));
      }

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set(Map<String, dynamic>.from(product));
      }
    } catch (e) {
      debugPrint("Wishlist Error: $e");
      // If both server and cache fail, we notify the UI
      rethrow;
    }
  }

  // Stream for the heart icon on Dashboard (Real-time)
  static Stream<bool> isInWishlistStream(String? productName) {
    if (productName == null) return Stream.value(false);

    final wishlist = _userWishlist;
    if (wishlist == null) return Stream.value(false);
    
    final docId = generateDocId(productName);
    return wishlist.doc(docId).snapshots().map((snapshot) => snapshot.exists);
  }

  // Stream for the Wishlist Screen (Real-time)
  static Stream<List<Map<String, dynamic>>> get wishlistStream {
    final wishlist = _userWishlist;
    if (wishlist == null) return Stream.value([]);
    
    return wishlist.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Clear all items from the wishlist
  static Future<void> clearWishlist() async {
    try {
      final wishlist = _userWishlist;
      if (wishlist == null) return;

      final snapshot = await wishlist.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Clear Wishlist Error: $e");
    }
  }
}
