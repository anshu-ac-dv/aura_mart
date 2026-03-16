import 'package:aura_mart/Screens/MyOrdersScreen.dart';
import 'package:aura_mart/Screens/LoginScreen.dart';
import 'package:aura_mart/Services/CartService.dart';
import 'package:aura_mart/Services/OrderService.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text("Choose Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPaymentMethodTile(Icons.credit_card, "Card", isDarkMode),
            _buildPaymentMethodTile(Icons.account_balance_wallet, "UPI / Wallet", isDarkMode),
            _buildPaymentMethodTile(Icons.payments, "Cash on Delivery", isDarkMode),
            const SizedBox(height: 20),
            // FIXED: Removed SliverToBoxAdapter which was causing a crash inside Column
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _processCheckout();
                },
                child: const Text("PLACE YOUR ORDER", style: TextStyle(fontWeight: FontWeight.bold)),
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
      title: Text(title, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 15)),
      trailing: const Icon(Icons.circle_outlined, size: 20),
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
        Fluttertoast.showToast(msg: "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final items = CartService.cartItems;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopHeader(isDarkMode),
                _buildLocationBar(isDarkMode),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmptyState(isDarkMode)
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, i) => _buildCartItem(items[i], i, isDarkMode),
                        ),
                ),
                if (items.isNotEmpty) _buildSummarySection(isDarkMode),
                const SizedBox(height: 100),
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withAlpha(150),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            if (_showSuccessAnimation) _buildSuccessOverlay(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isDarkMode) {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "YOUR CART",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildLocationBar(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: Colors.deepPurple.withAlpha(30)),
      child: const Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
          SizedBox(width: 5),
          Text("Deliver to Anshu - New Delhi 110001", style: TextStyle(color: Colors.white, fontSize: 12)),
          Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 80, width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item['icon'], color: Colors.deepPurple, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 5),
                  Text('\$${item['price']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _qtyBtn(Icons.remove, isDarkMode, () => setState(() => CartService.decrementQty(index))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      _qtyBtn(Icons.add, isDarkMode, () => setState(() => CartService.incrementQty(index))),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                        onPressed: () => setState(() => CartService.removeItem(index)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildSummarySection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text("\$${_totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showPaymentOptions(isDarkMode),
              child: const Text("PROCEED TO CHECKOUT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 20),
                const Text("Order Placed!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() => _showSuccessAnimation = false);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                  },
                  child: const Text("VIEW ORDERS"),
                ),
                TextButton(
                  onPressed: () => setState(() => _showSuccessAnimation = false),
                  child: const Text("CONTINUE SHOPPING", style: TextStyle(color: Colors.deepPurple)),
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
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 15),
          const Text("Your cart is empty", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
