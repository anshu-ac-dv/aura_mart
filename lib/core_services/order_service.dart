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
    if (orders == null) throw Exception("Please login to place an order");
    if (items.isEmpty) throw Exception("Cannot place an order with an empty cart");

    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
    
    // Clean items list to ensure no direct FieldValues are passed inside the array
    // Firestore allows Timestamps, but it's safer to have a clean list.
    final List<Map<String, dynamic>> cleanItems = items.map((item) {
      return {
        'id': item['id']?.toString() ?? '',
        'name': item['name']?.toString() ?? 'Unknown Item',
        'price': (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0,
        'image': item['image']?.toString() ?? '',
        'qty': (item['qty'] is num) ? (item['qty'] as num).toInt() : 1,
        'category': item['category']?.toString() ?? '',
      };
    }).toList();

    await orders.doc(orderId).set({
      'orderId': orderId,
      'items': cleanItems,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': 'Processing',
      'orderDate': FieldValue.serverTimestamp(),
      'localTimestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> seedSampleOrders() async {
    final List<Map<String, dynamic>> items = [
      {
        'id': 'sample_1',
        'name': 'Aura Studio Headphones',
        'price': 299.0,
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500',
        'qty': 1,
        'category': 'Electronics',
      }
    ];
    await createOrder(items, 299.0, "Sample Payment");
  }

  // Stream of all orders for real-time UI
  static Stream<List<Map<String, dynamic>>> get ordersStream {
    final orders = _userOrders;
    if (orders == null) return Stream.value([]);
    
    // We can't orderBy a field that might be null (like serverTimestamp before it syncs)
    // if we want to show it immediately in offline mode.
    // Instead, we'll order by orderId which is a timestamp-based string.
    return orders.orderBy('orderId', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
