import 'package:aura_mart/features/cart/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.category,
    required super.qty,
    super.addedAt,
    required super.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json, String docId) {
    dynamic priceVal = json['price'] ?? 0.0;
    double price = 0.0;
    if (priceVal is String) {
      price = double.tryParse(priceVal.replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0.0;
    } else if (priceVal is num) {
      price = priceVal.toDouble();
    }

    return CartItemModel(
      id: docId,
      name: json['name'] ?? 'Unknown',
      price: price,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      qty: (json['qty'] is num) ? (json['qty'] as num).toInt() : 1,
      addedAt: json['addedAt'],
      updatedAt: (json['updatedAt'] is num) ? (json['updatedAt'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'qty': qty,
      'addedAt': addedAt,
      'updatedAt': updatedAt,
    };
  }

  static String generateDocId(Map<String, dynamic> product) {
    if (product['id'] != null) return product['id'].toString();
    final name = product['name']?.toString() ?? 'unknown';
    return name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }
}
