import 'package:aura_mart/Screens/MyOrdersScreen.dart';
import 'package:aura_mart/Services/CartService.dart';
import 'package:aura_mart/Services/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _showSuccessAnimation = false;

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

  double get _totalPrice => CartService.totalPrice;

  void _showPaymentOptions(bool isDarkMode) {
    if (CartService.cartItems.isEmpty) {
      Fluttertoast.showToast(msg: "Your cart is empty!");
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text("Select Payment Method", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPaymentMethodTile(Icons.credit_card, "Credit / Debit Card", isDarkMode),
            _buildPaymentMethodTile(Icons.account_balance_wallet, "UPI / Google Pay", isDarkMode),
            _buildPaymentMethodTile(Icons.payments, "Cash on Delivery", isDarkMode),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _processCheckout();
                },
                child: const Text("PAY NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(IconData icon, String title, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
      trailing: const Icon(Icons.radio_button_off, size: 20),
      onTap: () {},
    );
  }

  void _processCheckout() async {
    setState(() => _isProcessing = true);
    try {
      List<Map<String, dynamic>> orderItems = CartService.getSerializableItems();
      await OrderService.createOrder(orderItems, _totalPrice);
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _showSuccessAnimation = true;
          CartService.clearCart();
        });
        _successController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        Fluttertoast.showToast(msg: "Order failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final items = CartService.cartItems;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // --- PREMIUM HEADER ---
              Container(
                padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Cart',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text('Check your items before checkout', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                    )
                  ],
                ),
              ),

              // --- CART ITEMS LIST ---
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) => _buildCartItem(items[i], i, isDarkMode),
                      ),
              ),

              // --- CHECKOUT SUMMARY SECTION ---
              if (items.isNotEmpty) _buildCheckoutSection(isDarkMode),
              const SizedBox(height: 100),
            ],
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text("Processing Order...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          if (_showSuccessAnimation) _buildSuccessOverlay(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, bool isDarkMode) {
    return Dismissible(
      key: Key(item['name'] + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          CartService.removeItem(index);
        });
        Fluttertoast.showToast(msg: "${item['name']} removed");
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(25)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              height: 70, width: 70,
              decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Icon(item['icon'], color: Colors.deepPurple, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 4),
                  Text('\$${item['price']}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            _buildQtyControl(index, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyControl(int index, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(color: isDarkMode ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: const EdgeInsets.all(8), constraints: const BoxConstraints(),
            icon: Icon(Icons.remove, size: 18, color: isDarkMode ? Colors.white70 : Colors.black54),
            onPressed: () => setState(() { CartService.decrementQty(index); }),
          ),
          Text('${CartService.cartItems[index]['qty']}', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          IconButton(
            padding: const EdgeInsets.all(8), constraints: const BoxConstraints(),
            icon: const Icon(Icons.add, size: 18, color: Colors.deepPurple),
            onPressed: () => setState(() { CartService.incrementQty(index); }),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600], fontSize: 16)),
              Text('\$${_totalPrice.toStringAsFixed(2)}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
              ),
              onPressed: () => _showPaymentOptions(isDarkMode),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
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
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 100),
                ),
                const SizedBox(height: 20),
                const Text("Order Placed!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                const Text("Your order has been placed successfully.", style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    setState(() => _showSuccessAnimation = false);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                  },
                  child: const Text("VIEW MY ORDERS", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => setState(() => _showSuccessAnimation = false),
                  child: const Text("CONTINUE SHOPPING", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                )
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
          Icon(Icons.shopping_basket_outlined, size: 100, color: isDarkMode ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 20),
          Text('Your cart is empty', style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white38 : Colors.grey[400], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
