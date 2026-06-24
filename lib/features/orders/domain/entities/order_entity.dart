import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String orderId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final dynamic orderDate;

  const OrderEntity({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    this.orderDate,
  });

  @override
  List<Object?> get props => [orderId, items, totalAmount, paymentMethod, status, orderDate];
}

class OrderItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;
  final int qty;
  final String category;

  const OrderItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.qty,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, price, image, qty, category];
}
