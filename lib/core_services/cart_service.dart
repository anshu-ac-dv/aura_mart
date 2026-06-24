import 'package:aura_mart/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:aura_mart/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:aura_mart/features/cart/domain/entities/cart_item.dart';
import 'package:aura_mart/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter/foundation.dart';

/// AuraCartService now acts as a Service Locator / Bridge to the Clean Architecture implementation.
/// This maintains backward compatibility with the existing UI calls.
class AuraCartService {
  static final CartRepository _repository = CartRepositoryImpl(
    remoteDataSource: CartRemoteDataSourceImpl(),
  );

  static Future<void> addToCart(Map<String, dynamic> product, {int quantity = 1}) async {
    try {
      await _repository.addToCart(product, quantity: quantity);
      debugPrint("Successfully added to cart");
    } catch (e) {
      debugPrint("Add to Cart Error: $e");
      rethrow;
    }
  }

  static Future<void> addAllToCart(List<Map<String, dynamic>> items) async {
    try {
      await _repository.addAllToCart(items);
    } catch (e) {
      debugPrint("Add All to Cart Error: $e");
      rethrow;
    }
  }

  static Future<void> incrementQty(String docId) async {
    try {
      await _repository.incrementQty(docId);
    } catch (e) {
      debugPrint("Increment Qty Error: $e");
    }
  }

  static Future<void> decrementQty(String docId, int currentQty) async {
    try {
      await _repository.decrementQty(docId, currentQty);
    } catch (e) {
      debugPrint("Decrement Qty Error: $e");
    }
  }

  static Future<void> removeItem(String docId) async {
    try {
      await _repository.removeItem(docId);
    } catch (e) {
      debugPrint("Remove Item Error: $e");
    }
  }

  static Future<void> clearCart() async {
    try {
      await _repository.clearCart();
    } catch (e) {
      debugPrint("Clear Cart Error: $e");
    }
  }

  /// Original cartStream returning List<Map<String, dynamic>> for backward compatibility
  static Stream<List<Map<String, dynamic>>> get cartStream {
    return _repository.getCartStream().map((items) {
      return items.map((item) => {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'image': item.image,
        'category': item.category,
        'qty': item.qty,
        'addedAt': item.addedAt,
        'updatedAt': item.updatedAt,
      }).toList();
    });
  }

  /// New cartItemStream for Clean Architecture usage
  static Stream<List<CartItem>> get cartItemStream => _repository.getCartStream();

  static double calculateTotal(List<dynamic> items) {
    if (items is List<CartItem>) {
      return _repository.calculateTotal(items);
    }
    // Fallback for List<Map<String, dynamic>>
    return items.fold(0.0, (total, item) {
      final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
      final qty = (item['qty'] is num) ? (item['qty'] as num).toInt() : 0;
      return total + (price * qty);
    });
  }
}
