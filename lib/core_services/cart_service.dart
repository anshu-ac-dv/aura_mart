import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EloriaCartService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>? get _userCart {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('cart');
  }

  // Temporary local list for backward compatibility if needed, 
  // but we should move to Streams.
  static final List<Map<String, dynamic>> cartItems = [];

  static Future<void> addToCart(Map<String, dynamic> product) async {
    final cart = _userCart;
    if (cart == null) return;

    final name = product['name']?.toString() ?? 'Unknown';
    final docId = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final docRef = cart.doc(docId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({'qty': FieldValue.increment(1)});
    } else {
      dynamic priceVal = product['price'] ?? 0.0;
      double price = 0.0;
      if (priceVal is String) {
        price = double.tryParse(priceVal.replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
      } else if (priceVal is num) {
        price = priceVal.toDouble();
      }

      await docRef.set({
        'name': name,
        'price': price,
        'image': product['image'] ?? '',
        'category': product['category'] ?? '',
        'qty': 1,
      });
    }
  }

  static Future<void> incrementQty(String name) async {
    final cart = _userCart;
    if (cart == null) return;
    final docId = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    await cart.doc(docId).update({'qty': FieldValue.increment(1)});
  }

  static Future<void> decrementQty(String name, int currentQty) async {
    final cart = _userCart;
    if (cart == null) return;
    final docId = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    if (currentQty > 1) {
      await cart.doc(docId).update({'qty': FieldValue.increment(-1)});
    } else {
      await cart.doc(docId).delete();
    }
  }

  static Future<void> removeItem(String name) async {
    final cart = _userCart;
    if (cart == null) return;
    final docId = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    await cart.doc(docId).delete();
  }

  static Future<void> clearCart() async {
    final cart = _userCart;
    if (cart == null) return;
    final snapshot = await cart.get();
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Stream<List<Map<String, dynamic>>> get cartStream {
    final cart = _userCart;
    if (cart == null) return Stream.value([]);
    return cart.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  static double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0, (total, item) => total + ((item['price'] as num) * (item['qty'] as num)));
  }

  // Legacy support for totalPrice if needed without stream
  static double get totalPrice {
    return 0.0; // Should use calculateTotal with stream data
  }
}
