import 'package:aura_mart/core_services/cart_service.dart';
import 'package:aura_mart/core_services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Header Image with Hero Animation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Hero(
              tag: 'prod_${product['id']}',
              child: CachedNetworkImage(
                imageUrl: product['image'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: isDarkMode ? Colors.white10 : Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              ),
            ),
          ),

          // Custom Back & Wishlist Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBlurButton(
                    onTap: () => Navigator.pop(context), 
                    icon: Icons.arrow_back_ios_new_rounded,
                    isDarkMode: isDarkMode,
                  ),
                  StreamBuilder<bool>(
                    stream: AuraWishlistService.isInWishlistStream(product),
                    builder: (context, snapshot) {
                      bool isFav = snapshot.data ?? false;
                      return _buildBlurButton(
                        onTap: () => AuraWishlistService.toggleWishlist(product),
                        icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : null,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Content Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDarkMode ? 100 : 20),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 10),
                    Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withAlpha(100), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 25),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${product['price']}", style: TextStyle(color: primaryColor, fontSize: 28, fontWeight: FontWeight.w900)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text("4.8 (120 reviews)", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(product['name'] ?? 'Premium Product', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      product['description'] ?? "Experience premium quality with this carefully curated selection from Aura Mart. Designed for those who appreciate fine craftsmanship and modern aesthetics.", 
                      style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[600], height: 1.6, fontSize: 14),
                    ),
                    
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        _buildQtyBtn(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }, isDarkMode),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("$_quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        _buildQtyBtn(Icons.add, () { setState(() => _quantity++); }, isDarkMode),
                      ],
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              );
            },
          ),

          // Bottom Navigation
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    for(int i=0; i<_quantity; i++) {
                      await AuraCartService.addToCart(product);
                    }
                    Fluttertoast.showToast(msg: "Added to Bag");
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Failed to add to cart");
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("ADD TO BAG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurButton({required VoidCallback onTap, required IconData icon, Color? color, required bool isDarkMode}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12), 
            color: isDarkMode ? Colors.black.withAlpha(100) : Colors.white.withAlpha(150), 
            child: Icon(icon, color: color ?? (isDarkMode ? Colors.white : Colors.black87), size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.withAlpha(50)), 
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
        ), 
        child: Icon(icon, size: 20),
      ),
    );
  }
}
