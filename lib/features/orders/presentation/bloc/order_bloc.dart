import 'dart:async';
import 'package:aura_mart/features/orders/domain/repositories/order_repository.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_event.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  StreamSubscription? _orderSubscription;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<OrderStarted>(_onOrderStarted);
    on<OrdersUpdated>(_onOrdersUpdated);
    on<OrderCreated>(_onOrderCreated);
  }

  Future<void> _onOrderStarted(OrderStarted event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    await _orderSubscription?.cancel();
    _orderSubscription = orderRepository.ordersStream.listen((orders) {
      add(OrdersUpdated(orders));
    });
  }

  void _onOrdersUpdated(OrdersUpdated event, Emitter<OrderState> emit) {
    emit(OrderLoaded(event.orders));
  }

  Future<void> _onOrderCreated(OrderCreated event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await orderRepository.createOrder(event.items, event.totalAmount, event.paymentMethod);
      emit(OrderSuccess());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}
