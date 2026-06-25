import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_mart/features/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<void> addToCart(Map<String, dynamic> product, {int quantity});
  Future<void> addAllToCart(List<Map<String, dynamic>> items);
  Future<void> incrementQty(String docId);
  Future<void> decrementQty(String docId, int currentQty);
  Future<void> removeItem(String docId);
  Future<void> clearCart();
  Stream<List<CartItemModel>> getCartStream();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CartRemoteDataSourceImpl({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _userCart {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('cart');
  }

  @override
  Future<void> addToCart(Map<String, dynamic> product, {int quantity = 1}) async {
    final cart = _userCart;
    if (cart == null) throw Exception("Please login to add items to cart");

    final docId = CartItemModel.generateDocId(product);
    final docRef = cart.doc(docId);

    final model = CartItemModel.fromJson(product, docId);

    // Optimized check: Use default get() which handles cache/server automatically
    final doc = await docRef.get();
    final exists = doc.exists;

    if (exists) {
      await docRef.update({
        'qty': FieldValue.increment(quantity),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'price': model.price,
      });
    } else {
      await docRef.set({
        ...model.toJson(),
        'qty': quantity,
        'id': docId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  @override
  Future<void> addAllToCart(List<Map<String, dynamic>> items) async {
    final cart = _userCart;
    if (cart == null) return;

    final batch = _db.batch();
    for (var item in items) {
      final docId = CartItemModel.generateDocId(item);
      final docRef = cart.doc(docId);
      final model = CartItemModel.fromJson(item, docId);

      batch.set(docRef, {
        ...model.toJson(),
        'qty': FieldValue.increment(item['qty'] ?? 1),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
      
      batch.set(docRef, {
        'addedAt': FieldValue.serverTimestamp(), 
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<void> incrementQty(String docId) async {
    final cart = _userCart;
    if (cart == null) return;
    await cart.doc(docId).update({
      'qty': FieldValue.increment(1),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> decrementQty(String docId, int currentQty) async {
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
  }

  @override
  Future<void> removeItem(String docId) async {
    final cart = _userCart;
    if (cart == null) return;
    await cart.doc(docId).delete();
  }

  @override
  Future<void> clearCart() async {
    final cart = _userCart;
    if (cart == null) return;
    final snapshot = await cart.get();
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Stream<List<CartItemModel>> getCartStream() {
    final cart = _userCart;
    if (cart == null) return Stream.value([]);
    
    return cart.snapshots().map((s) {
      return s.docs.map((d) => CartItemModel.fromJson(d.data(), d.id)).toList();
    });
  }
}
