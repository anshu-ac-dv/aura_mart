import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>? get _userPaymentMethods {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('payment_methods');
  }

  static Future<void> savePaymentMethod(Map<String, dynamic> paymentData) async {
    final methods = _userPaymentMethods;
    if (methods == null) throw Exception("User not logged in");

    final newDoc = methods.doc();
    paymentData['id'] = newDoc.id;
    await newDoc.set(paymentData);
  }

  static Future<void> deletePaymentMethod(String methodId) async {
    final methods = _userPaymentMethods;
    if (methods == null) return;
    await methods.doc(methodId).delete();
  }

  static Stream<List<Map<String, dynamic>>> get paymentMethodsStream {
    final methods = _userPaymentMethods;
    if (methods == null) return Stream.value([]);
    
    return methods.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
