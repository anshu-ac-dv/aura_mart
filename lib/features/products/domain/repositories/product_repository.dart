import 'package:aura_mart/features/products/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Stream<List<ProductEntity>> get productsStream;
  Stream<List<ProductEntity>> getProductsByCategory(String category);
  Stream<List<ProductEntity>> get sellerProductsStream;
  Future<void> addProduct(Map<String, dynamic> productData);
  Future<void> deleteProduct(String productId);
}
