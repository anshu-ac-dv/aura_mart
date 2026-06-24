import 'package:aura_mart/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<void> createOrder(List<OrderItemEntity> items, double totalAmount, String paymentMethod);
  Stream<List<OrderEntity>> get ordersStream;
}
