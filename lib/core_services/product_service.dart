import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _products {
    return _db.collection('products');
  }

  static Future<void> addProduct(Map<String, dynamic> productData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    productData['sellerId'] = user.uid;
    productData['sellerName'] = user.displayName ?? "Unknown Seller";
    productData['createdAt'] = FieldValue.serverTimestamp();
    
    await _products.add(productData);
  }

  static Stream<List<Map<String, dynamic>>> get productsStream {
    return _products.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> get sellerProductsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _products
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }
}
