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
                      return const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(child: CircularProgressIndicator()),
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
              ? Theme.of(context).primaryColor.withOpacity(0.1) 
              : (isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02)),
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
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          final total = AuraCartService.calculateTotal(items);

          return Stack(
            children: [
              // Ambient Glows
              if (isDarkMode) ...[
                Positioned(left: -100, top: -100, child: _buildGlow(primaryColor.withOpacity(0.1), 400)),
                Positioned(right: -50, bottom: 200, child: _buildGlow(Colors.blueAccent.withOpacity(0.05), 300)),
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
                          "YOUR CURATED COLLECTION",
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
                                return const SizedBox(height: 200); // Bottom padding for sticky button
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
                  child: Center(child: CircularProgressIndicator(color: primaryColor))
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
    final double price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
    
    return Dismissible(
      key: Key(name),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        AuraCartService.removeItem(name);
        Fluttertoast.showToast(msg: "$name removed");
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03)),
          boxShadow: [
            if (!isDarkMode) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 10)),
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
    final String name = item['name']?.toString() ?? '';
    final int qty = ((item['qty'] ?? 1) as num).toInt();
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16), 
            onPressed: () => AuraCartService.decrementQty(name, qty),
            constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
          ),
          Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          IconButton(
            icon: const Icon(Icons.add, size: 16), 
            onPressed: () => AuraCartService.incrementQty(name),
            constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(bool isDarkMode, List<Map<String, dynamic>> items, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () => _showPaymentOptions(isDarkMode, items, total),
                    child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    'https://lottie.host/8017e887-848e-4903-88da-901d812a67e0/S30043uX9K.json', 
                    height: 200,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Lottie.network(
              'https://lottie.host/9e4d5f7b-1a9c-46a4-9e32-f2a8c3d8d672/6zV7Y5WpLp.json', 
              height: 150,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Your bag is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text('Time to start curating.', style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 12)),
        ],
      ),
    );
  }
}
