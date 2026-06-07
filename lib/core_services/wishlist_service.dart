import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuraWishlistService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>? get _userWishlist {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('wishlist');
  }

  /// Unified ID generation to prevent mismatches.
  static String _getDocId(Map<String, dynamic> product) {
    if (product['id'] != null) return product['id'].toString();
    final name = product['name']?.toString() ?? 'unknown';
    return name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  static Future<void> toggleWishlist(Map<String, dynamic> product) async {
    try {
      final wishlist = _userWishlist;
      if (wishlist == null) throw Exception("User not logged in");

      final docId = _getDocId(product);
      final docRef = wishlist.doc(docId);

      DocumentSnapshot doc;
      try {
        doc = await docRef.get(const GetOptions(source: Source.serverAndCache));
      } catch (e) {
        doc = await docRef.get(const GetOptions(source: Source.cache));
      }

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set(Map<String, dynamic>.from(product));
      }
    } catch (e) {
      debugPrint("Wishlist Error: $e");
      rethrow;
    }
  }

  static Stream<bool> isInWishlistStream(Map<String, dynamic> product) {
    final wishlist = _userWishlist;
    if (wishlist == null) return Stream.value(false);
    
    final docId = _getDocId(product);
    return wishlist.doc(docId).snapshots().map((snapshot) => snapshot.exists);
  }

  static Stream<List<Map<String, dynamic>>> get wishlistStream {
    final wishlist = _userWishlist;
    if (wishlist == null) return Stream.value([]);
    
    return wishlist.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Future<void> clearWishlist() async {
    try {
      final wishlist = _userWishlist;
      if (wishlist == null) return;

      final snapshot = await wishlist.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Clear Wishlist Error: $e");
    }
  }
}
