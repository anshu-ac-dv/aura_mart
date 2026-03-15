import 'package:aura_mart/Services/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: OrderService.ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final orders = snapshot.data ?? [];

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

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order, bool isDarkMode) {
    // Safely handling the date conversion from Firestore Timestamp
    DateTime date = DateTime.now();
    if (order['orderDate'] != null) {
      if (order['orderDate'] is Timestamp) {
        date = (order['orderDate'] as Timestamp).toDate();
      } else if (order['orderDate'] is DateTime) {
        date = order['orderDate'];
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
            "Order #${order['orderId']}",
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
                      order['status'] ?? 'Processing',
                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "\$${order['totalAmount']}",
                    style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(indent: 20, endIndent: 20),
            ...(order['items'] as List? ?? []).map((item) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.withAlpha(26),
                  child: const Icon(Icons.shopping_bag, color: Colors.deepPurple, size: 20),
                ),
                title: Text(item['name'] ?? 'Unknown Item', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black)),
                trailing: Text("x${item['qty'] ?? 1}", style: const TextStyle(color: Colors.grey)),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
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
