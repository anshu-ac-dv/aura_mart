import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Safely get user's addresses collection reference
  static CollectionReference<Map<String, dynamic>>? get _userAddresses {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('addresses');
  }

  // Logic: Add or Update Address
  static Future<void> saveAddress(Map<String, dynamic> addressData, {String? docId}) async {
    final addresses = _userAddresses;
    if (addresses == null) throw Exception("User not logged in");

    if (docId != null) {
      // Update existing
      await addresses.doc(docId).update(addressData);
    } else {
      // Add new
      final newDoc = addresses.doc();
      addressData['id'] = newDoc.id;
      addressData['isDefault'] = false; // Initial address logic
      await newDoc.set(addressData);
    }
  }

  // Logic: Set Default Address
  static Future<void> setDefaultAddress(String addressId) async {
    final addresses = _userAddresses;
    if (addresses == null) return;

    // Get all addresses to reset defaults
    final allDocs = await addresses.get();
    WriteBatch batch = _db.batch();

    for (var doc in allDocs.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }

    await batch.commit();
  }

  // Logic: Delete Address
  static Future<void> deleteAddress(String addressId) async {
    final addresses = _userAddresses;
    if (addresses == null) return;
    await addresses.doc(addressId).delete();
  }

  // Stream of addresses for real-time UI
  static Stream<List<Map<String, dynamic>>> get addressesStream {
    final addresses = _userAddresses;
    if (addresses == null) return Stream.value([]);
    
    return addresses.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
