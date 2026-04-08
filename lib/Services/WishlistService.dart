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
  static String generateDocId(String? name) {
    if (name == null || name.isEmpty) return "unknown_product";
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  // Logic: Add or Remove product from Firestore
  static Future<void> toggleWishlist(Map<String, dynamic> product) async {
    try {
      final wishlist = _userWishlist;
      if (wishlist == null) throw Exception("User not logged in");

      final String? name = product['name']?.toString();
      if (name == null) return;

      final docId = generateDocId(name);
      final docRef = wishlist.doc(docId);

      // We'll use a transaction or a simple check-and-set. 
      // Given the 'unavailable' error, it might be due to offline persistence issues 
      // or network instability. Let's try to set it with a timeout or handle it gracefully.
      
      final doc = await docRef.get(const GetOptions(source: Source.serverAndCache)).timeout(const Duration(seconds: 5));
      if (doc.exists) {
        await docRef.delete().timeout(const Duration(seconds: 5));
      } else {
        // Ensure we save the product data as a dynamic map
        await docRef.set(Map<String, dynamic>.from(product)).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      print("Wishlist Error: $e");
      // If it's a network issue, Firestore should normally queue it if persistence is enabled.
      // But we are seeing [cloud_firestore/unavailable].
      rethrow;
    }
  }

  // Stream for the heart icon on Dashboard (Real-time)
  static Stream<bool> isInWishlistStream(String? productName) {
    if (productName == null) return Stream.value(false);

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
