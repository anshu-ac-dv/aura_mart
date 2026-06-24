import 'dart:async';
import 'package:aura_mart/features/cart/domain/entities/cart_item.dart';
import 'package:aura_mart/features/cart/domain/repositories/cart_repository.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_event.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;
  StreamSubscription? _cartSubscription;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<CartStarted>(_onCartStarted);
    on<_CartUpdated>(_onCartUpdated);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartQtyIncremented>(_onCartQtyIncremented);
    on<CartQtyDecremented>(_onCartQtyDecremented);
    on<CartCleared>(_onCartCleared);
  }

  Future<void> _onCartStarted(CartStarted event, Emitter<CartState> emit) async {
    emit(CartLoading());
    await _cartSubscription?.cancel();
    _cartSubscription = cartRepository.getCartStream().listen((items) {
      add(_CartUpdated(items));
    });
  }

  void _onCartUpdated(_CartUpdated event, Emitter<CartState> emit) {
    final total = cartRepository.calculateTotal(event.items);
    emit(CartLoaded(items: event.items, total: total));
  }

  Future<void> _onCartItemAdded(CartItemAdded event, Emitter<CartState> emit) async {
    try {
      await cartRepository.addToCart(event.product, quantity: event.quantity);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCartItemRemoved(CartItemRemoved event, Emitter<CartState> emit) async {
    await cartRepository.removeItem(event.docId);
  }

  Future<void> _onCartQtyIncremented(CartQtyIncremented event, Emitter<CartState> emit) async {
    await cartRepository.incrementQty(event.docId);
  }

  Future<void> _onCartQtyDecremented(CartQtyDecremented event, Emitter<CartState> emit) async {
    await cartRepository.decrementQty(event.docId, event.currentQty);
  }

  Future<void> _onCartCleared(CartCleared event, Emitter<CartState> emit) async {
    await cartRepository.clearCart();
  }
}

class _CartUpdated extends CartEvent {
  final List<CartItem> items;
  const _CartUpdated(this.items);
  @override
  List<Object?> get props => [items];
}
