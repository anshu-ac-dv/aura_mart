import 'package:aura_mart/features/products/data/datasources/product_remote_data_source.dart';
import 'package:aura_mart/features/products/domain/entities/product_entity.dart';
import 'package:aura_mart/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ProductEntity>> get productsStream => remoteDataSource.productsStream;

  @override
  Stream<List<ProductEntity>> getProductsByCategory(String category) => remoteDataSource.getProductsByCategory(category);

  @override
  Stream<List<ProductEntity>> get sellerProductsStream => remoteDataSource.sellerProductsStream;

  @override
  Future<void> addProduct(Map<String, dynamic> productData) async {
    return await remoteDataSource.addProduct(productData);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    return await remoteDataSource.deleteProduct(productId);
  }
}
