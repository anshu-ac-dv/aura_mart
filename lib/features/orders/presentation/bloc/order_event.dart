import 'package:aura_mart/features/orders/domain/entities/order_entity.dart';
import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderStarted extends OrderEvent {}

class OrderCreated extends OrderEvent {
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String paymentMethod;

  const OrderCreated({
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [items, totalAmount, paymentMethod];
}

class OrdersUpdated extends OrderEvent {
  final List<OrderEntity> orders;
  const OrdersUpdated(this.orders);
  @override
  List<Object?> get props => [orders];
}
