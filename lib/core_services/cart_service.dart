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

  static Future<void> addToCart(Map<String, dynamic> product) async {
    try {
      final cart = _userCart;
      if (cart == null) throw Exception("User not logged in");

      final docId = _getDocId(product);
      final docRef = cart.doc(docId);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({
          'qty': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        dynamic priceVal = product['price'] ?? 0.0;
        double price = 0.0;
        if (priceVal is String) {
          price = double.tryParse(priceVal.replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
        } else if (priceVal is num) {
          price = priceVal.toDouble();
        }

        await docRef.set({
          'name': product['name'] ?? 'Unknown',
          'price': price,
          'image': product['image'] ?? '',
          'category': product['category'] ?? '',
          'qty': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
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
        'updatedAt': FieldValue.serverTimestamp(),
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
          'updatedAt': FieldValue.serverTimestamp(),
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
    // Order by addedAt to keep the cart organized (newest first)
    return cart.orderBy('addedAt', descending: true).snapshots().map((s) => s.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return data;
    }).toList());
  }

  static double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
      final qty = (item['qty'] is num) ? (item['qty'] as num).toInt() : 0;
      return total + (price * qty);
    });
  }
}
