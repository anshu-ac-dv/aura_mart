import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Safely get user's orders collection reference
  static CollectionReference<Map<String, dynamic>>? get _userOrders {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('orders');
  }

  // Logic: Create a new order
  static Future<void> createOrder(List<Map<String, dynamic>> items, double totalAmount, String paymentMethod) async {
    final orders = _userOrders;
    if (orders == null) throw Exception("User not logged in");

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    await orders.doc(orderId).set({
      'orderId': orderId,
      'items': items,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': 'Processing',
      'orderDate': FieldValue.serverTimestamp(),
    });
  }

  // Stream of all orders for real-time UI
  static Stream<List<Map<String, dynamic>>> get ordersStream {
    final orders = _userOrders;
    if (orders == null) return Stream.value([]);
    
    return orders.orderBy('orderDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
