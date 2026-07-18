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
    return _products.orderBy('createdAt', descending: true).limit(50).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> getProductsByCategoryStream(String category) {
    return _products
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
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

  static Future<void> seedSampleProducts() async {
    final samples = [
      {
        'name': 'Premium Wireless Headphones',
        'price': 299.0,
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=800',
        'description': 'Experience studio-quality sound with active noise cancellation.',
        'category': 'Electronics',
      },
      {
        'name': 'Urban Sport Sneakers',
        'price': 120.0,
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800',
        'description': 'Lightweight and durable sneakers for your daily urban adventures.',
        'category': 'Fashion',
      },
      {
        'name': 'Modern Smart Watch',
        'price': 199.0,
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800',
        'description': 'Stay connected and track your fitness with our latest smartwatch.',
        'category': 'Electronics',
      },
      {
        'name': 'Minimalist Leather Wallet',
        'price': 45.0,
        'image': 'https://images.unsplash.com/photo-1627123424574-724758594e93?q=80&w=800',
        'description': 'Handcrafted premium leather wallet for the modern professional.',
        'category': 'Fashion',
      },
      {
        'name': 'Designer Coffee Table',
        'price': 350.0,
        'image': 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=800',
        'description': 'Elegant and functional coffee table to complement any living space.',
        'category': 'Home',
      },
      {
        'name': 'Organic Skincare Set',
        'price': 85.0,
        'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=800',
        'description': 'Complete set of organic products for a healthy and glowing skin.',
        'category': 'Beauty',
      },
    ];

    for (var product in samples) {
      await addProduct(product);
    }
  }
}
