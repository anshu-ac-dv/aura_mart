import 'package:aura_mart/screens/my_orders_screen.dart';
import 'package:aura_mart/core_services/cart_service.dart';
import 'package:aura_mart/core_services/order_service.dart';
import 'package:aura_mart/core_services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

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

  late Stream<List<Map<String, dynamic>>> _cartStream;
  late Stream<List<Map<String, dynamic>>> _paymentMethodsStream;
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _cartStream = AuraCartService.cartStream;
    _paymentMethodsStream = PaymentService.paymentMethodsStream;
    
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 30),
              const Text("Checkout", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: 2)),
              const SizedBox(height: 10),
              Text("Choose your payment method", style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38, fontSize: 13)),
              const SizedBox(height: 30),
              Flexible(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _paymentMethodsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Lottie.network(
                            'https://lottie.host/5053b53a-c852-473d-9f79-66c82705b768/0F8C6m2GkM.json',
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    
                    final methods = snapshot.data ?? [];
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        ...methods.map((method) {
                          bool isSelected = _selectedPaymentMethodId == method['id']?.toString();
                          return _buildPaymentTile(
                            method['value']?.toString() ?? 'Payment Method',
                            method['type'] == 'upi' ? Icons.account_balance_wallet_outlined : Icons.credit_card_outlined,
                            isSelected,
                            isDarkMode,
                            () {
                              setModalState(() {
                                _selectedPaymentMethodId = method['id']?.toString();
                                _selectedPaymentMethodValue = method['value']?.toString();
                              });
                            }
                          );
                        }),
                        _buildPaymentTile(
                          "Cash on Delivery",
                          Icons.payments_outlined,
                          _selectedPaymentMethodId == 'cod',
                          isDarkMode,
                          () {
                            setModalState(() {
                              _selectedPaymentMethodId = 'cod';
                              _selectedPaymentMethodValue = "Cash on Delivery";
                            });
                          }
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: _selectedPaymentMethodId == null ? null : () {
                    Navigator.pop(sheetContext);
                    _processCheckout(items, total);
                  },
                  child: const Text("PLACE ORDER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String title, IconData icon, bool isSelected, bool isDarkMode, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withAlpha(26) 
              : (isDarkMode ? Colors.white.withAlpha(8) : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : (isDarkMode ? Colors.white38 : Colors.black38)),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
          ],
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
    AuraCartService.clearCart();
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
      _onOrderSuccess();
    } catch (e) {
      setState(() => _isProcessing = false);
      Fluttertoast.showToast(msg: "Order failed: $e");
    }
  }

  void _showCODAlert(List<Map<String, dynamic>> items, double total) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: const Text("Confirm Order", style: TextStyle(fontWeight: FontWeight.w200, letterSpacing: 1)),
          content: const Text("Place order with Cash on Delivery?", style: TextStyle(fontSize: 14, color: Colors.grey)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Text("Error loading cart", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => setState(() { _cartStream = AuraCartService.cartStream; }),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return Center(
              child: Lottie.network(
                'https://lottie.host/5053b53a-c852-473d-9f79-66c82705b768/0F8C6m2GkM.json',
                height: 200,
                errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(),
              ),
            );
          }

          final items = snapshot.data ?? [];
          final total = AuraCartService.calculateTotal(items);

          return Stack(
            children: [
              // Ambient Glows
              if (isDarkMode) ...[
                Positioned(left: -100, top: -100, child: _buildGlow(primaryColor.withAlpha(26), 400)),
                Positioned(right: -50, bottom: 200, child: _buildGlow(Colors.blueAccent.withAlpha(13), 300)),
              ],

              Column(
                children: [
                  // Cinematic Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MY BAG",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 8,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "AURA MART",
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: items.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            physics: const BouncingScrollPhysics(),
                            itemCount: items.length + 1, // Add space for sticky panel
                            itemBuilder: (context, i) {
                              if (i == items.length) {
                                return const SizedBox(height: 250); // Bottom padding for sticky button
                              }
                              return _buildModernCartItem(items[i], isDarkMode);
                            },
                          ),
                  ),
                ],
              ),

              // Sticky Checkout Panel at bottom
              if (items.isNotEmpty) 
                Positioned(
                  bottom: 110, // Above navigation bar
                  left: 0,
                  right: 0,
                  child: _buildCheckoutPanel(isDarkMode, items, total),
                ),

              if (_isProcessing) 
                Container(
                  color: Colors.black54, 
                  child: Center(
                    child: Lottie.network(
                      'https://lottie.host/5053b53a-c852-473d-9f79-66c82705b768/0F8C6m2GkM.json',
                      height: 150,
                      errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              if (_showSuccessAnimation) _buildSuccessOverlay(isDarkMode),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  Widget _buildModernCartItem(Map<String, dynamic> item, bool isDarkMode) {
    final String name = item['name']?.toString() ?? 'Unknown';
    final String id = item['id']?.toString() ?? name;
    final double price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
    
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        AuraCartService.removeItem(id);
        Fluttertoast.showToast(msg: "$name removed");
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(26),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(8) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(8)),
          boxShadow: [
            if (!isDarkMode) BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 15, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: item['image'] ?? '', 
                height: 90, 
                width: 90, 
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: isDarkMode ? Colors.white10 : Colors.black12),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text('\$${price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  _buildQtyControl(item, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyControl(Map<String, dynamic> item, bool isDarkMode) {
    final String id = item['id']?.toString() ?? '';
    final int qty = ((item['qty'] ?? 1) as num).toInt();
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16), 
            onPressed: () => AuraCartService.decrementQty(id, qty),
            constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
          ),
          Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          IconButton(
            icon: const Icon(Icons.add, size: 16), 
            onPressed: () => AuraCartService.incrementQty(id),
            constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(bool isDarkMode, List<Map<String, dynamic>> items, double total) {
    const double shipping = 10.0;
    final double grandTotal = total + shipping;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withAlpha(13) : Colors.white.withAlpha(204),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPriceRow("Subtotal", "\$${total.toStringAsFixed(2)}", isDarkMode),
                const SizedBox(height: 8),
                _buildPriceRow("Delivery", "\$${shipping.toStringAsFixed(2)}", isDarkMode),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('\$${grandTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Theme.of(context).primaryColor)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () => _showPaymentOptions(isDarkMode, items, grandTotal),
                    child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white38 : Colors.black38)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSuccessOverlay(bool isDarkMode) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: isDarkMode ? Colors.black.withAlpha(204) : Colors.white.withAlpha(204),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    'https://lottie.host/8e202580-0441-4770-9831-77864f1d77a8/0L4BwHqC9M.json', 
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
                  ),
                  const Text("Success", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w100, letterSpacing: 4)),
                  const SizedBox(height: 10),
                  const Text("Order has been placed", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: Lottie.network(
                'https://lottie.host/9e4d5f7b-1a9c-46a4-9e32-f2a8c3d8d672/6zV7Y5WpLp.json', 
                height: 180,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Your bag is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w200, letterSpacing: 2)),
            const SizedBox(height: 10),
            Text('Time to start curating your premium collection.', 
              textAlign: TextAlign.center,
              style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 13)
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "Discover items in the Home tab");
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text("SHOP NOW", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
