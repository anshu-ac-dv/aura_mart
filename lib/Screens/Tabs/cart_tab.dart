import 'package:aura_mart/Screens/MyOrdersScreen.dart';
import 'package:aura_mart/Services/CartService.dart';
import 'package:aura_mart/Services/OrderService.dart';
import 'package:aura_mart/Services/PaymentService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _showSuccessAnimation = false;
  String? _selectedPaymentMethodId;
  String? _selectedPaymentMethodValue;

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _showPaymentOptions(bool isDarkMode, List<Map<String, dynamic>> items, double total) {
    if (items.isEmpty) {
      Fluttertoast.showToast(msg: "Your cart is empty!");
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Select Payment Method", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: PaymentService.paymentMethodsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading methods", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)));
                    }
                    final methods = snapshot.data ?? [];
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        ...methods.map((method) {
                          IconData icon = method['type'] == 'upi' ? Icons.account_balance_wallet : Icons.credit_card;
                          return ListTile(
                            leading: Icon(icon, color: Colors.deepPurple),
                            title: Text(method['value']?.toString() ?? 'Payment Method', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                            trailing: Icon(
                              _selectedPaymentMethodId == method['id']?.toString() ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: Colors.deepPurple,
                            ),
                            onTap: () {
                              setModalState(() {
                                _selectedPaymentMethodId = method['id']?.toString();
                                _selectedPaymentMethodValue = method['value']?.toString();
                              });
                              setState(() {}); 
                            },
                          );
                        }),
                        ListTile(
                          leading: const Icon(Icons.payments, color: Colors.deepPurple),
                          title: Text("Cash on Delivery", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                          trailing: Icon(
                            _selectedPaymentMethodId == 'cod' ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: Colors.deepPurple,
                          ),
                          onTap: () {
                            setModalState(() {
                              _selectedPaymentMethodId = 'cod';
                              _selectedPaymentMethodValue = "Cash on Delivery";
                            });
                            setState(() {});
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _selectedPaymentMethodId == null ? null : () {
                    Navigator.pop(context);
                    _processCheckout(items, total);
                  },
                  child: const Text("PAY NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOrderSuccess() {
    setState(() {
      _isProcessing = false;
      _showSuccessAnimation = true;
      _selectedPaymentMethodId = null;
      _selectedPaymentMethodValue = null;
    });
    CartService.clearCart();
    _successController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showSuccessAnimation) {
        setState(() {
          _showSuccessAnimation = false;
          _successController.reset();
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
      }
    });
  }

  void _processCheckout(List<Map<String, dynamic>> items, double total) async {
    if (_selectedPaymentMethodValue == null) return;
    if (_selectedPaymentMethodId == 'cod') {
      _showCODAlert(items, total);
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await OrderService.createOrder(items, total, _selectedPaymentMethodValue!);
      await Future.delayed(const Duration(seconds: 2));
      _onOrderSuccess();
    } catch (e) {
      setState(() => _isProcessing = false);
      Fluttertoast.showToast(msg: "Order failed: $e");
    }
  }

  void _showCODAlert(List<Map<String, dynamic>> items, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Order"),
        content: const Text("Place order with Cash on Delivery?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                await OrderService.createOrder(items, total, "Cash on Delivery");
                _onOrderSuccess();
              } catch (e) {
                setState(() => _isProcessing = false);
                Fluttertoast.showToast(msg: "Order failed: $e");
              }
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CartService.cartStream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final total = CartService.calculateTotal(items);

          return Stack(
            children: [
              Column(
                children: [
                  RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Cart', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('Real-time shopping bag', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: items.length,
                            itemBuilder: (context, i) => RepaintBoundary(child: _buildCartItem(items[i], isDarkMode)),
                          ),
                  ),
                  if (items.isNotEmpty) RepaintBoundary(child: _buildCheckoutSection(isDarkMode, items, total)),
                  const SizedBox(height: 100),
                ],
              ),
              if (_isProcessing) 
                Container(
                  color: Colors.black54, 
                  child: const Center(child: CircularProgressIndicator(color: Colors.white))
                ),
              if (_showSuccessAnimation) _buildSuccessOverlay(isDarkMode),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(imageUrl: item['image'], height: 70, width: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${(item['price'] as num).toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildQtyControl(item, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildQtyControl(Map<String, dynamic> item, bool isDarkMode) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => CartService.decrementQty(item['name']?.toString() ?? '', (item['qty'] as num).toInt())),
        Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple), onPressed: () => CartService.incrementQty(item['name']?.toString() ?? '')),
      ],
    );
  }

  Widget _buildCheckoutSection(bool isDarkMode, List<Map<String, dynamic>> items, double total) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 16)),
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _showPaymentOptions(isDarkMode, items, total),
              child: const Text('PROCEED TO PAY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(bool isDarkMode) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.network('https://lottie.host/8017e887-848e-4903-88da-901d812a67e0/S30043uX9K.json', height: 250),
                const Text("Order Placed!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
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
          Lottie.network('https://lottie.host/9e4d5f7b-1a9c-46a4-9e32-f2a8c3d8d672/6zV7Y5WpLp.json', height: 200),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
