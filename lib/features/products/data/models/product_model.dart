import 'package:aura_mart/features/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.category,
    required super.description,
    required super.sellerId,
    required super.sellerName,
    super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String docId) {
    return ProductModel(
      id: docId,
      name: json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': createdAt,
    };
  }
}
