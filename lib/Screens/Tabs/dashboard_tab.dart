import 'package:eloria_collection/screens/login_screen.dart';
import 'package:eloria_collection/core_services/cart_service.dart';
import 'package:eloria_collection/core_services/product_service.dart';
import 'package:eloria_collection/core_services/wishlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";
  late Stream<List<Map<String, dynamic>>> _productStream;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded},
    {'name': 'Home', 'icon': Icons.home_filled},
    {'name': 'Beauty', 'icon': Icons.auto_awesome_rounded},
    {'name': 'Mobiles', 'icon': Icons.smartphone_rounded},
  ];

  final List<Map<String, dynamic>> _mockProducts = [
    {'name': 'Eloria Buds Pro', 'price': 129.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Urban Sneakers', 'price': 89.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Elite SmartWatch', 'price': 199.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1544117518-30df578096a4?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Artisan Coffee', 'price': 55.0, 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Pro Gamer Mouse', 'price': 45.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1527814050087-37a3d71ae69c?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Vogue Leather Bag', 'price': 149.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=1000&auto=format&fit=crop'},
  ];

  @override
  void initState() {
    super.initState();
    _productStream = ProductService.productsStream;
  }

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productStream,
        builder: (context, snapshot) {
          final allProducts = snapshot.data ?? [];
          final marketplaceProducts = allProducts.where((p) {
            final matchesSearch = p['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
            final matchesCategory = _selectedCategory == "All" || p['category'] == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();
          
          final isWaiting = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- PREMIUM BRAND HEADER ---
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: _searchQuery.isNotEmpty 
                      ? Text("Search Results", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16))
                      : null,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 60, 25, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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

              // --- GREETING & SEARCH ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${user?.displayName?.split(' ').first ?? 'Friend'}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Discover Your Aura",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Search Bar
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: "Find your style...",
                            hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26),
                            prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- CATEGORY STRIP ---
              SliverToBoxAdapter(
                child: Container(
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
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : (isDarkMode ? Colors.white12 : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white10 : Colors.black12)),
                          ),
                          child: Row(
                            children: [
                              Icon(cat['icon'], size: 16, color: isSelected ? Colors.white : (isDarkMode ? Colors.white38 : Colors.black38)),
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
                ),
              ),

              // --- HERO CARD (ONLY IF NO SEARCH) ---
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        image: const DecorationImage(
                          image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1000"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          ),
                        ),
                        padding: const EdgeInsets.all(25),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SEASONAL", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            Text("Modern Minimalism", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // --- NEW ARRIVALS (HORIZONTAL) ---
              if (allProducts.isNotEmpty && _searchQuery.isEmpty) ...[
                _buildSectionHeaderSliver("New Arrivals", isDarkMode),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: allProducts.length > 5 ? 5 : allProducts.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalCard(allProducts[index], isDarkMode, index + 2000);
                      },
                    ),
                  ),
                ),
              ],

              // --- CURATED SPECIALS (GRID) ---
              if (_filteredMocks.isNotEmpty) ...[
                _buildSectionHeaderSliver("Curated Specials", isDarkMode),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredMocks[index], isDarkMode, index);
                    },
                    childCount: _filteredMocks.length,
                  ),
                ),
              ],

              // --- MARKETPLACE SECTION ---
              _buildSectionHeaderSliver(_searchQuery.isEmpty ? "Marketplace" : "Search Results", isDarkMode),
              if (isWaiting)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator())))
              else if (snapshot.hasError)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Error loading data", style: TextStyle(color: Colors.grey)))))
              else if (marketplaceProducts.isEmpty)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(80), child: Text("No items found", style: TextStyle(color: Colors.grey)))))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    itemBuilder: (context, index) {
                      return _buildProductCard(marketplaceProducts[index], isDarkMode, index + 1000);
                    },
                    childCount: marketplaceProducts.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeaderSliver(String title, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 35, 25, 15),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: isDarkMode ? Colors.white38 : Colors.black38),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    final price = (product['price'] ?? 0).toString();
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 15, right: 5, bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if (!isDarkMode) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: product['image'] ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(color: isDarkMode ? Colors.white10 : Colors.black12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("\$$price", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    final price = (product['price'] ?? 0).toString();
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: product['image'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(height: 150, color: isDarkMode ? Colors.white10 : Colors.black12),
                ),
              ),
              Positioned(top: 8, right: 8, child: _buildWishlistBtn(product)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$$price", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)),
                    GestureDetector(
                      onTap: () {
                        EloriaCartService.addToCart(product);
                        Fluttertoast.showToast(msg: "Added to Bag");
                      },
                      child: Icon(Icons.add_shopping_cart_rounded, size: 18, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistBtn(Map<String, dynamic> product) {
    return StreamBuilder<bool>(
      stream: EloriaWishlistService.isInWishlistStream(product['name']),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => EloriaWishlistService.toggleWishlist(product),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 16, color: isFav ? Colors.redAccent : Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(bool isDarkMode) {
    return IconButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
      },
      icon: Icon(Icons.logout_rounded, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
    );
  }
}
