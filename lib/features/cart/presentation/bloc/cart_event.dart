import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {}

class CartItemAdded extends CartEvent {
  final Map<String, dynamic> product;
  final int quantity;

  const CartItemAdded(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class CartItemRemoved extends CartEvent {
  final String docId;

  const CartItemRemoved(this.docId);

  @override
  List<Object?> get props => [docId];
}

class CartQtyIncremented extends CartEvent {
  final String docId;

  const CartQtyIncremented(this.docId);

  @override
  List<Object?> get props => [docId];
}

class CartQtyDecremented extends CartEvent {
  final String docId;
  final int currentQty;

  const CartQtyDecremented(this.docId, this.currentQty);

  @override
  List<Object?> get props => [docId, currentQty];
}

class CartCleared extends CartEvent {}
