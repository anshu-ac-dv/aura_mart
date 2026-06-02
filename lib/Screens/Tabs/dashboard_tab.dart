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
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Colors.grey},
    {'name': 'Fashion', 'icon': Icons.shopping_bag_rounded, 'color': Colors.pink},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    {'name': 'Home', 'icon': Icons.home_filled, 'color': Colors.green},
    {'name': 'Beauty', 'icon': Icons.auto_awesome_rounded, 'color': Colors.purple},
  ];

  final List<Map<String, dynamic>> _allProducts = [
    {'name': 'Eloria Buds Pro', 'price': 129.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Urban Sneakers', 'price': 89.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Elite SmartWatch', 'price': 199.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1544117518-30df578096a4?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Artisan Coffee', 'price': 55.0, 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Pro Gamer Mouse', 'price': 45.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1527814050087-37a3d71ae69c?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Vogue Leather Bag', 'price': 149.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=1000&auto=format&fit=crop'},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch = p['name']!.toString().toLowerCase().contains(_searchQuery.toLowerCase());
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

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // UNIQUE EDITORIAL HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DISCOVER",
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w200,
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      _buildLogoutButton(isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Eloria Collection",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // UNIQUE SEARCH PILL
          SliverPersistentHeader(
            pinned: true,
            delegate: _PillSearchDelegate(
              child: _buildSearchPill(isDarkMode),
            ),
          ),

          // CATEGORY STRIP
          SliverToBoxAdapter(child: _buildCategoryStrip(isDarkMode)),

          // BENTO HIGHLIGHT
          SliverToBoxAdapter(child: _buildBentoHighlight(isDarkMode)),

          // STAGGERED MARKETPLACE (Mock Products)
          if (_filteredProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                itemBuilder: (context, index) {
                  return _buildModernBentoCard(_filteredProducts[index], isDarkMode, index);
                },
                childCount: _filteredProducts.length,
              ),
            ),

          // SELLER MARKETPLACE (Firestore Products)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
              child: Text(
                "Marketplace",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ProductService.productsStream,
            builder: (context, snapshot) {
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("No items listed by sellers yet.", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  itemBuilder: (context, index) {
                    return _buildModernBentoCard(products[index], isDarkMode, index + _filteredProducts.length);
                  },
                  childCount: products.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (r) => false,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12),
        ),
        child: const Icon(Icons.logout_rounded, size: 18),
      ),
    );
  }

  Widget _buildSearchPill(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Search Eloria...",
            hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.deepPurple),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStrip(bool isDarkMode) {
    return SizedBox(
      height: 70,
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
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : (isDarkMode ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  cat['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

  Widget _buildBentoHighlight(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          image: const DecorationImage(
            image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000&auto=format&fit=crop"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withAlpha(150), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(25),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Limited Edition",
                style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10),
              ),
              SizedBox(height: 5),
              Text(
                "Eloria Studio Series",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBentoCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    bool isTall = index % 3 == 0;
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          EloriaCartService.addToCart(product);
          Fluttertoast.showToast(msg: "Added to cart");
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF151515) : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: product['image']!.toString(),
                      height: isTall ? 240 : 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: _buildWishlistButton(product),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']!.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${product['price']}",
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
                        ),
                        const Icon(Icons.add_circle_outline_rounded, size: 20),
                      ],
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
    return StreamBuilder<bool>(
      stream: EloriaWishlistService.isInWishlistStream(product['name']!),
      builder: (context, snapshot) {
        bool isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => EloriaWishlistService.toggleWishlist(product),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withAlpha(20),
                child: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 16, color: isFav ? Colors.red : Colors.white),
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
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
