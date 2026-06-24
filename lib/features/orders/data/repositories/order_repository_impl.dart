import 'package:aura_mart/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:aura_mart/features/orders/data/models/order_model.dart';
import 'package:aura_mart/features/orders/domain/entities/order_entity.dart';
import 'package:aura_mart/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createOrder(List<OrderItemEntity> items, double totalAmount, String paymentMethod) async {
    final models = items.map((e) => OrderItemModel(
      id: e.id,
      name: e.name,
      price: e.price,
      image: e.image,
      qty: e.qty,
      category: e.category,
    )).toList();
    return await remoteDataSource.createOrder(models, totalAmount, paymentMethod);
  }

  @override
  Stream<List<OrderEntity>> get ordersStream => remoteDataSource.ordersStream;
}
