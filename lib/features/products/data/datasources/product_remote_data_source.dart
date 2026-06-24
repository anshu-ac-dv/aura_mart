import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_mart/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Stream<List<ProductModel>> get productsStream;
  Stream<List<ProductModel>> getProductsByCategory(String category);
  Stream<List<ProductModel>> get sellerProductsStream;
  Future<void> addProduct(Map<String, dynamic> productData);
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProductRemoteDataSourceImpl({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _products => _db.collection('products');

  @override
  Stream<List<ProductModel>> get productsStream {
    return _products.orderBy('createdAt', descending: true).limit(50).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _products
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<ProductModel>> get sellerProductsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _products
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addProduct(Map<String, dynamic> productData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    productData['sellerId'] = user.uid;
    productData['sellerName'] = user.displayName ?? "Unknown Seller";
    productData['createdAt'] = FieldValue.serverTimestamp();
    
    await _products.add(productData);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }
}
