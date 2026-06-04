import 'package:eloria_collection/screens/login_screen.dart';
import 'package:eloria_collection/core_services/cart_service.dart';
import 'package:eloria_collection/core_services/product_service.dart';
import 'package:eloria_collection/core_services/wishlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Fashion', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded},
    {'name': 'Home', 'icon': Icons.home_filled},
    {'name': 'Beauty', 'icon': Icons.auto_awesome_rounded},
  ];

  final List<Map<String, dynamic>> _mockProducts = [
    {'name': 'Eloria Buds Pro', 'price': 129.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Urban Sneakers', 'price': 89.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Elite SmartWatch', 'price': 199.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1544117518-30df578096a4?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Artisan Coffee', 'price': 55.0, 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Pro Gamer Mouse', 'price': 45.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1527814050087-37a3d71ae69c?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Vogue Leather Bag', 'price': 149.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=1000&auto=format&fit=crop'},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _mockProducts.where((p) {
      final matchesSearch = p['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchesCategory = _selectedCategory == "All" || p['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: Stack(
        children: [
          // Background soft glows
          if (isDarkMode) ...[
            _buildGlow(primaryColor.withAlpha(25), const Offset(-100, -100), 400),
            _buildGlow(primaryColor.withAlpha(20), const Offset(200, 300), 300),
          ],
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "WELCOME TO",
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Eloria",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: 2,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          _buildLogoutButton(isDarkMode),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // SEARCH BAR (Sticky)
              SliverPersistentHeader(
                pinned: true,
                delegate: _PillSearchDelegate(
                  child: _buildSearchPill(isDarkMode),
                ),
              ),

              // CATEGORIES
              SliverToBoxAdapter(child: _buildCategoryStrip(isDarkMode)),

              // PROMO SECTION
              SliverToBoxAdapter(child: _buildFeaturedPromotion(isDarkMode)),

              // PRODUCTS GRID (MOCKS)
              if (_filteredProducts.isNotEmpty) ...[
                _buildSectionHeader("Curated for you", isDarkMode),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    itemBuilder: (context, index) {
                      return _buildPremiumProductCard(_filteredProducts[index], isDarkMode, index);
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ],

              // MARKETPLACE (REAL DATA)
              _buildSectionHeader("Marketplace", isDarkMode),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: ProductService.productsStream,
                builder: (context, snapshot) {
                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: Text("Waiting for new arrivals...", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      itemBuilder: (context, index) {
                        return _buildPremiumProductCard(products[index], isDarkMode, index + 100);
                      },
                      childCount: products.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, Offset offset, double size) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDarkMode) {
    return InkWell(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Icons.power_settings_new_rounded, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildSearchPill(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(13)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: "Search collections...",
                hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26),
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStrip(bool isDarkMode) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : (isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8)),
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).primaryColor.withAlpha(77), blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
              child: Center(
                child: Text(
                  cat['name'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : (isDarkMode ? Colors.white54 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedPromotion(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 20, offset: const Offset(0, 10))],
          image: const DecorationImage(
            image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [Colors.black.withAlpha(204), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(25),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SEASONAL", style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("The Winter\nEdit 2026", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w200, height: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumProductCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    bool isTall = index % 3 == 0;
    final String name = product['name']?.toString() ?? 'Unknown';
    final String image = product['image']?.toString() ?? '';
    final String category = product['category']?.toString().toUpperCase() ?? "";
    final double price = (product['price'] is num) ? (product['price'] as num).toDouble() : 0.0;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          EloriaCartService.addToCart(product);
          Fluttertoast.showToast(msg: "Added to your collection");
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withAlpha(8) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      height: isTall ? 240 : 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: isDarkMode ? Colors.white10 : Colors.black12),
                      errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  Positioned(top: 12, right: 12, child: _buildWishlistButton(product)),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: Colors.black.withAlpha(77),
                          child: Text(
                            "\$$price",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(fontSize: 9, letterSpacing: 1, color: isDarkMode ? Colors.white30 : Colors.black38, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistButton(Map<String, dynamic> product) {
    final String name = product['name']?.toString() ?? 'Unknown';
    return StreamBuilder<bool>(
      stream: EloriaWishlistService.isInWishlistStream(name),
      builder: (context, snapshot) {
        bool isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => EloriaWishlistService.toggleWishlist(product),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white.withAlpha(51),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 16,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PillSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _PillSearchDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 75;
  @override
  double get minExtent => 75;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
