import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Reference to the user's specific wishlist collection
  static CollectionReference<Map<String, dynamic>> get _userWishlist {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(uid).collection('wishlist');
  }

  // Add or Remove product from Firestore
  static Future<void> toggleWishlist(Map<String, String> product) async {
    final docId = product['name']!.replaceAll(' ', '_').toLowerCase();
    final docRef = _userWishlist.doc(docId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete(); // Remove if exists
    } else {
      await docRef.set(product); // Add if doesn't exist
    }
  }

  // Check if a product is in wishlist (Stream for real-time UI updates)
  static Stream<bool> isInWishlistStream(String productName) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(false);
    
    final docId = productName.replaceAll(' ', '_').toLowerCase();
    return _userWishlist.doc(docId).snapshots().map((snapshot) => snapshot.exists);
  }

  // Stream of all wishlist items
  static Stream<List<Map<String, dynamic>>> get wishlistStream {
    return _userWishlist.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
