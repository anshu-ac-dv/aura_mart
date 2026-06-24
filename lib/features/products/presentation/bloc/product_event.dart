import 'package:aura_mart/features/products/domain/entities/product_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductsFetched extends ProductEvent {}

class ProductsByCategoryRequested extends ProductEvent {
  final String category;
  const ProductsByCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}

class ProductsUpdated extends ProductEvent {
  final List<ProductEntity> products;
  const ProductsUpdated(this.products);
  @override
  List<Object?> get props => [products];
}
