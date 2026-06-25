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
        'name': 'Aura Studio Headphones',
        'price': 299.0,
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500',
        'description': 'High-fidelity audio with active noise cancellation and premium comfort.',
        'category': 'Electronics',
      },
      {
        'name': 'Midnight Running Shoes',
        'price': 120.0,
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500',
        'description': 'Engineered for speed and comfort with advanced cushioning technology.',
        'category': 'Fashion',
      },
      {
        'name': 'Minimalist Oak Desk',
        'price': 450.0,
        'image': 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?q=80&w=500',
        'description': 'Handcrafted solid oak desk with a sleek design for modern workspaces.',
        'category': 'Home',
      },
      {
        'name': 'Silk Glow Face Serum',
        'price': 55.0,
        'image': 'https://images.unsplash.com/photo-1594465919760-441fe5908ab0?q=80&w=500',
        'description': 'Revitalize your skin with our organic botanical serum for a natural glow.',
        'category': 'Beauty',
      },
    ];

    for (var product in samples) {
      await addProduct(product);
    }
  }
}
