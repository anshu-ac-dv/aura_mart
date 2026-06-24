import 'package:aura_mart/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<void> addToCart(Map<String, dynamic> product, {int quantity});
  Future<void> addAllToCart(List<Map<String, dynamic>> items);
  Future<void> incrementQty(String docId);
  Future<void> decrementQty(String docId, int currentQty);
  Future<void> removeItem(String docId);
  Future<void> clearCart();
  Stream<List<CartItem>> getCartStream();
  double calculateTotal(List<CartItem> items);
}
