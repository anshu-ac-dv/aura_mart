import 'package:aura_mart/core_services/wishlist_service.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_event.dart';
import 'package:aura_mart/features/products/domain/entities/product_entity.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_bloc.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_event.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_state.dart';
import 'package:aura_mart/screens/products/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductsByCategoryRequested(widget.categoryName));
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: widget.categoryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best of ${widget.categoryName}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Explore our curated collection',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }

                final products = state is ProductLoaded ? state.products : [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: isDarkMode ? Colors.white24 : Colors.grey[300]),
                        const SizedBox(height: 20),
                        const Text("No products found in this category", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, product, isDarkMode);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product, bool isDarkMode) {
    final pMap = {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'category': product.category,
      'description': product.description,
      'sellerId': product.sellerId,
      'sellerName': product.sellerName,
    };

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: pMap))),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    child: Hero(
                      tag: 'prod_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: StreamBuilder<bool>(
                      stream: AuraWishlistService.isInWishlistStream(pMap),
                      builder: (context, snapshot) {
                        bool isFav = snapshot.data ?? false;
                        return CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white.withAlpha(230),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 18, color: Colors.red),
                            onPressed: () async {
                              await AuraWishlistService.toggleWishlist(pMap);
                              Fluttertoast.showToast(msg: isFav ? "Removed from Wishlist" : "Added to Wishlist");
                            },
                          ),
                        );
                      }
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price}",
                        style: TextStyle(
                          color: widget.categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.read<CartBloc>().add(CartItemAdded(pMap));
                          Fluttertoast.showToast(msg: "Added to Bag");
                        },
                        child: Icon(Icons.add_shopping_cart, color: widget.categoryColor, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
