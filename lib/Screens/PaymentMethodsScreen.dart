import 'package:aura_mart/Services/PaymentService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: PaymentService.paymentMethodsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final methods = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: InkWell(
                  onTap: () => _showAddPaymentMethodDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.withAlpha(50)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.deepPurple),
                        SizedBox(width: 15),
                        Text("Add a new payment method", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: methods.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: methods.length,
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          return _buildPaymentMethodCard(method, isDarkMode);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, bool isDarkMode) {
    IconData icon;
    String typeLabel;
    switch (method['type']) {
      case 'upi':
        icon = Icons.account_balance_wallet;
        typeLabel = 'UPI ID';
        break;
      case 'card':
        icon = Icons.credit_card;
        typeLabel = method['cardType'] == 'debit' ? 'Debit Card' : 'Credit Card';
        break;
      default:
        icon = Icons.payment;
        typeLabel = 'Payment Method';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(method['value'], style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => PaymentService.deletePaymentMethod(method['id']),
          )
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Select Payment Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
            title: const Text("UPI ID"),
            onTap: () {
              Navigator.pop(context);
              _showAddUPIForm();
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.deepPurple),
            title: const Text("Credit / Debit Card"),
            onTap: () {
              Navigator.pop(context);
              _showAddCardForm();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddUPIForm() {
    final upiController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add UPI ID", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: upiController,
              decoration: const InputDecoration(labelText: "UPI ID (e.g., user@upi)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                onPressed: () async {
                  if (upiController.text.isNotEmpty) {
                    await PaymentService.savePaymentMethod({
                      'type': 'upi',
                      'value': upiController.text,
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: "UPI ID saved");
                    }
                  }
                },
                child: const Text("SAVE UPI ID"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddCardForm() {
    final cardNoController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    String cardType = 'debit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Card Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: cardType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'debit', child: Text("Debit Card")),
                  DropdownMenuItem(value: 'credit', child: Text("Credit Card")),
                ],
                onChanged: (val) => setState(() => cardType = val!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cardNoController,
                decoration: const InputDecoration(labelText: "Card Number", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(labelText: "Expiry (MM/YY)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(labelText: "CVV", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (cardNoController.text.length >= 16) {
                      String maskedValue = "**** **** **** ${cardNoController.text.substring(cardNoController.text.length - 4)}";
                      await PaymentService.savePaymentMethod({
                        'type': 'card',
                        'cardType': cardType,
                        'value': maskedValue,
                      });
                      if (mounted) {
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Card saved");
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Please enter a valid card number");
                    }
                  },
                  child: const Text("SAVE CARD"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 80, color: isDarkMode ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("No payment methods saved yet.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
