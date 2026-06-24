import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final String sellerId;
  final String sellerName;
  final dynamic createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.sellerId,
    required this.sellerName,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, price, image, category, description, sellerId, sellerName, createdAt];
}
