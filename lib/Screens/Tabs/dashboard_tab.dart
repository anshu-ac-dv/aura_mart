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
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded},
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

  List<Map<String, dynamic>> get _filteredMocks {
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
          
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ProductService.productsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProducts = snapshot.data ?? [];
              final marketplaceProducts = allProducts.where((p) {
                final matchesSearch = p['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
                final matchesCategory = _selectedCategory == "All" || p['category'] == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- PREMIUM BRAND HEADER ---
                  SliverAppBar(
                    expandedHeight: 120,
                    collapsedHeight: 80,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.fromLTRB(25, 60, 25, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ELORIA",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: 4,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  "COLLECTION",
                                  style: TextStyle(
                                    fontSize: 8,
                                    letterSpacing: 6,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            _buildLogoutButton(isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- STICKY SEARCH ---
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PillSearchDelegate(
                      child: _buildSearchPill(isDarkMode),
                    ),
                  ),

                  // --- CATEGORY CHIPS ---
                  SliverToBoxAdapter(child: _buildCategoryStrip(isDarkMode)),

                  // --- FEATURED HERO ---
                  SliverToBoxAdapter(child: _buildHeroCard(isDarkMode)),

                  // --- CURATED SECTION ---
                  if (_filteredMocks.isNotEmpty) ...[
                    _buildSectionHeader("Curated Specials", isDarkMode),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        itemBuilder: (context, index) {
                          return _buildModernProductCard(_filteredMocks[index], isDarkMode, index);
                        },
                        childCount: _filteredMocks.length,
                      ),
                    ),
                  ],

                  // --- MARKETPLACE SECTION ---
                  _buildSectionHeader("Marketplace", isDarkMode),
                  if (marketplaceProducts.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(80),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 40, color: isDarkMode ? Colors.white10 : Colors.black12),
                              const SizedBox(height: 15),
                              const Text("No items found", style: TextStyle(color: Colors.grey, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        itemBuilder: (context, index) {
                          return _buildModernProductCard(marketplaceProducts[index], isDarkMode, index + 1000);
                        },
                        childCount: marketplaceProducts.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
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
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isDarkMode ? Colors.white12 : Colors.black12),
          ],
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
          color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(10),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(10)),
        ),
        child: Icon(Icons.logout_rounded, size: 18, color: isDarkMode ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildSearchPill(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withAlpha(20) : Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(15)),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: "Find your style...",
                hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, letterSpacing: 1),
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 20),
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
      height: 60,
      margin: const EdgeInsets.only(top: 20),
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
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : (isDarkMode ? Colors.white.withAlpha(13) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white10 : Colors.black.withAlpha(10)),
                ),
                boxShadow: isSelected 
                    ? [BoxShadow(color: Theme.of(context).primaryColor.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))] 
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    cat['icon'], 
                    size: 16, 
                    color: isSelected ? Colors.white : (isDarkMode ? Colors.white38 : Colors.black38)
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white54 : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          image: const DecorationImage(
            image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1000"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.black.withAlpha(150),
                Colors.transparent,
                Colors.black.withAlpha(180),
              ],
            ),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "NEW SEASON",
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Modern\nMinimalism",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernProductCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    bool isTall = index % 3 == 0;
    final String name = product['name']?.toString() ?? 'Unknown';
    final String image = product['image']?.toString() ?? '';
    final String category = product['category']?.toString() ?? "";
    final double price = (product['price'] is num) ? (product['price'] as num).toDouble() : 0.0;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          // Future: Navigate to detail
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withAlpha(13) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE SECTION
              Stack(
                children: [
                  Hero(
                    tag: "prod_$index",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        height: isTall ? 220 : 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: isTall ? 220 : 180,
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(top: 15, right: 15, child: _buildWishlistButton(product)),
                  
                  // PRICE TAG
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Text(
                        "\$${price.toInt()}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              
              // INFO SECTION
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9, 
                        letterSpacing: 1.5, 
                        color: isDarkMode ? Colors.white38 : Colors.black38, 
                        fontWeight: FontWeight.w900
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white.withAlpha(220) : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        EloriaCartService.addToCart(product);
                        Fluttertoast.showToast(msg: "Added to Bag");
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(10)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "ADD TO BAG",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFav ? Colors.redAccent.withAlpha(40) : Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
