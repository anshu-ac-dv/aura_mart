import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Safely get the user's wishlist collection reference
  static CollectionReference<Map<String, dynamic>>? get _userWishlist {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('wishlist');
  }

  // Unified ID generation to prevent mismatches
  static String generateDocId(String name) {
    return name.toLowerCase().replaceAll(' ', '_').trim();
  }

  // Logic: Add or Remove product from Firestore
  static Future<void> toggleWishlist(Map<String, String> product) async {
    try {
      final wishlist = _userWishlist;
      if (wishlist == null) throw Exception("User not logged in");

      final docId = generateDocId(product['name']!);
      final docRef = wishlist.doc(docId);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set(product);
      }
    } catch (e) {
      print("Wishlist Error: $e");
      rethrow;
    }
  }

  // Stream for the heart icon on Dashboard (Real-time)
  static Stream<bool> isInWishlistStream(String productName) {
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
}
