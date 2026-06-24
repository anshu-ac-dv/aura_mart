import 'dart:async';
import 'package:aura_mart/features/products/domain/repositories/product_repository.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_event.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  StreamSubscription? _productSubscription;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<ProductsFetched>(_onProductsFetched);
    on<ProductsByCategoryRequested>(_onProductsByCategoryRequested);
    on<ProductsUpdated>(_onProductsUpdated);
  }

  Future<void> _onProductsFetched(ProductsFetched event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    await _productSubscription?.cancel();
    _productSubscription = productRepository.productsStream.listen((products) {
      add(ProductsUpdated(products));
    });
  }

  Future<void> _onProductsByCategoryRequested(ProductsByCategoryRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    await _productSubscription?.cancel();
    _productSubscription = productRepository.getProductsByCategory(event.category).listen((products) {
      add(ProductsUpdated(products));
    });
  }

  void _onProductsUpdated(ProductsUpdated event, Emitter<ProductState> emit) {
    emit(ProductLoaded(event.products));
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
