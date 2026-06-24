import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_mart/features/orders/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<void> createOrder(List<OrderItemModel> items, double totalAmount, String paymentMethod);
  Stream<List<OrderModel>> get ordersStream;
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  OrderRemoteDataSourceImpl({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _userOrders {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('orders');
  }

  @override
  Future<void> createOrder(List<OrderItemModel> items, double totalAmount, String paymentMethod) async {
    final orders = _userOrders;
    if (orders == null) throw Exception("Please login to place an order");

    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
    
    await orders.doc(orderId).set({
      'orderId': orderId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': 'Processing',
      'orderDate': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<OrderModel>> get ordersStream {
    final orders = _userOrders;
    if (orders == null) return Stream.value([]);
    
    return orders.orderBy('orderId', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
    });
  }
}
