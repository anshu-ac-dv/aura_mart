import 'package:aura_mart/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:aura_mart/features/cart/domain/entities/cart_item.dart';
import 'package:aura_mart/features/cart/domain/repositories/cart_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addToCart(Map<String, dynamic> product, {int quantity = 1}) async {
    return await remoteDataSource.addToCart(product, quantity: quantity);
  }

  @override
  Future<void> addAllToCart(List<Map<String, dynamic>> items) async {
    return await remoteDataSource.addAllToCart(items);
  }

  @override
  Future<void> incrementQty(String docId) async {
    return await remoteDataSource.incrementQty(docId);
  }

  @override
  Future<void> decrementQty(String docId, int currentQty) async {
    return await remoteDataSource.decrementQty(docId, currentQty);
  }

  @override
  Future<void> removeItem(String docId) async {
    return await remoteDataSource.removeItem(docId);
  }

  @override
  Future<void> clearCart() async {
    return await remoteDataSource.clearCart();
  }

  @override
  Stream<List<CartItem>> getCartStream() {
    return remoteDataSource.getCartStream().map((models) {
      final items = List<CartItem>.from(models);
      // Sort by addedAt descending
      items.sort((a, b) {
        final aTime = a.addedAt ?? 0;
        final bTime = b.addedAt ?? 0;
        num aVal = (aTime is Timestamp) ? aTime.millisecondsSinceEpoch : (aTime is num ? aTime : 0);
        num bVal = (bTime is Timestamp) ? bTime.millisecondsSinceEpoch : (bTime is num ? bTime : 0);
        return bVal.compareTo(aVal);
      });
      return items;
    });
  }

  @override
  double calculateTotal(List<CartItem> items) {
    return items.fold(0.0, (total, item) => total + (item.price * item.qty));
  }
}
