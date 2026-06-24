import 'package:aura_mart/features/orders/domain/entities/order_entity.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_event.dart';
import 'package:aura_mart/features/orders/presentation/bloc/order_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderStarted());
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (state is OrderError) {
            return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
          }

          final orders = state is OrderLoaded ? state.orders : [];

          if (orders.isEmpty) {
            return _buildEmptyState(isDarkMode);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order, isDarkMode);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order, bool isDarkMode) {
    DateTime date = DateTime.now();
    if (order.orderDate != null) {
      if (order.orderDate is Timestamp) {
        date = (order.orderDate as Timestamp).toDate();
      } else if (order.orderDate is DateTime) {
        date = order.orderDate;
      }
    }
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), 
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          iconColor: Colors.deepPurple,
          collapsedIconColor: Colors.grey,
          title: Text(
            "Order #${order.orderId}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "\$${order.totalAmount}",
                    style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusStep("Ordered", true, isDarkMode),
                  _buildStatusLine(true),
                  _buildStatusStep("Packed", false, isDarkMode),
                  _buildStatusLine(false),
                  _buildStatusStep("Shipped", false, isDarkMode),
                  _buildStatusLine(false),
                  _buildStatusStep("Delivered", false, isDarkMode),
                ],
              ),
            ),
            const Divider(indent: 20, endIndent: 20),
            ...order.items.map((item) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.image != ''
                        ? CachedNetworkImage(
                            imageUrl: item.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(Icons.shopping_bag, color: Colors.deepPurple, size: 20),
                            errorWidget: (context, url, error) => const Icon(Icons.shopping_bag, color: Colors.deepPurple, size: 20),
                          )
                        : const Icon(Icons.shopping_bag, color: Colors.deepPurple, size: 20),
                  ),
                ),
                title: Text(item.name, style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black)),
                trailing: Text("x${item.qty}", style: const TextStyle(color: Colors.grey)),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isComplete, bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isComplete ? Colors.green : (isDarkMode ? Colors.white10 : Colors.black12),
            shape: BoxShape.circle,
            border: isComplete ? null : Border.all(color: Colors.grey.withAlpha(50)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 8, color: isComplete ? (isDarkMode ? Colors.white70 : Colors.black87) : Colors.grey, fontWeight: isComplete ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStatusLine(bool isComplete) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: isComplete ? Colors.green : Colors.grey.withAlpha(50),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100, color: isDarkMode ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white38 : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
