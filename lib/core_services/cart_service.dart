import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuraCartService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>? get _userCart {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('cart');
  }

  /// Unified ID generation to prevent mismatches.
  /// Prioritizes product ID if available, otherwise generates a safe name-based ID.
  static String _getDocId(Map<String, dynamic> product) {
    if (product['id'] != null) return product['id'].toString();
    final name = product['name']?.toString() ?? 'unknown';
    return name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  static Future<void> addToCart(Map<String, dynamic> product, {int quantity = 1}) async {
    try {
      final cart = _userCart;
      if (cart == null) throw Exception("Please login to add items to cart");

      final docId = _getDocId(product);
      final docRef = cart.doc(docId);

      // Extract price safely before saving
      dynamic priceVal = product['price'] ?? 0.0;
      double price = 0.0;
      if (priceVal is String) {
        price = double.tryParse(priceVal.replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;
      } else if (priceVal is num) {
        price = priceVal.toDouble();
      }

      // Check existence robustly but efficiently
      DocumentSnapshot doc;
      try {
        doc = await docRef.get(const GetOptions(source: Source.cache));
      } catch (e) {
        // If not in cache, it might still exist on server
        try {
          doc = await docRef.get();
        } catch (e2) {
          // If still fails, we'll assume it's new and handle it in the set block
          // We can't easily 'throw' because it might be just offline
          // So we use a dummy snapshot that doesn't exist
          doc = await docRef.get(const GetOptions(source: Source.cache)).catchError((_) => doc);
        }
      }

      if (doc.exists) {
        // Update existing item
        await docRef.update({
          'qty': FieldValue.increment(quantity),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'price': price,
        });
      } else {
        // Add new item
        await docRef.set({
          'id': docId,
          'name': product['name'] ?? 'Unknown',
          'price': price,
          'image': product['image'] ?? '',
          'category': product['category'] ?? '',
          'qty': quantity,
          'addedAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
      debugPrint("Successfully added $docId to cart (x$quantity)");
    } catch (e) {
      debugPrint("Add to Cart Error: $e");
      rethrow;
    }
  }

  static Future<void> incrementQty(String docId) async {
    try {
      final cart = _userCart;
      if (cart == null) return;
      await cart.doc(docId).update({
        'qty': FieldValue.increment(1),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint("Increment Qty Error: $e");
    }
  }

  static Future<void> decrementQty(String docId, int currentQty) async {
    try {
      final cart = _userCart;
      if (cart == null) return;
      if (currentQty > 1) {
        await cart.doc(docId).update({
          'qty': FieldValue.increment(-1),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        await cart.doc(docId).delete();
      }
    } catch (e) {
      debugPrint("Decrement Qty Error: $e");
    }
  }

  static Future<void> removeItem(String docId) async {
    try {
      final cart = _userCart;
      if (cart == null) return;
      await cart.doc(docId).delete();
    } catch (e) {
      debugPrint("Remove Item Error: $e");
    }
  }

  static Future<void> clearCart() async {
    try {
      final cart = _userCart;
      if (cart == null) return;
      final snapshot = await cart.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Clear Cart Error: $e");
    }
  }

  static Stream<List<Map<String, dynamic>>> get cartStream {
    final cart = _userCart;
    if (cart == null) return Stream.value([]);
    
    // Use snapshots() and sort locally if needed, but Firestore orderBy is usually better.
    // If some docs are missing 'addedAt', they'll be hidden by orderBy.
    // We'll use a more permissive query and sort in Dart to ensure NO items are missed.
    return cart.snapshots().map((s) {
      final items = s.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
      
      // Sort by addedAt descending, handling potential nulls/mixed types
      items.sort((a, b) {
        final aTime = a['addedAt'] ?? 0;
        final bTime = b['addedAt'] ?? 0;
        // Handle both int and Timestamp if they exist
        num aVal = (aTime is Timestamp) ? aTime.millisecondsSinceEpoch : (aTime is num ? aTime : 0);
        num bVal = (bTime is Timestamp) ? bTime.millisecondsSinceEpoch : (bTime is num ? bTime : 0);
        return bVal.compareTo(aVal);
      });
      
      return items;
    });
  }

  static double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
      final qty = (item['qty'] is num) ? (item['qty'] as num).toInt() : 0;
      return total + (price * qty);
    });
  }
}
