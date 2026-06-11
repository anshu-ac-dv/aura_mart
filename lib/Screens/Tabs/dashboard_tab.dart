import 'package:aura_mart/screens/login_screen.dart';
import 'package:aura_mart/core_services/cart_service.dart';
import 'package:aura_mart/core_services/product_service.dart';
import 'package:aura_mart/core_services/wishlist_service.dart';
import 'package:aura_mart/screens/products/product_details_screen.dart';
import 'package:aura_mart/widgets/aura_skeletons.dart';
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
  late Stream<List<Map<String, dynamic>>> _productStream;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Colors.deepPurple},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Colors.pink},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    {'name': 'Home', 'icon': Icons.home_filled, 'color': Colors.green},
    {'name': 'Beauty', 'icon': Icons.auto_awesome_rounded, 'color': Colors.purple},
    {'name': 'Mobiles', 'icon': Icons.smartphone_rounded, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _productStream = ProductService.productsStream;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- DYNAMIC AMBIENT BACKGROUND ---
          if (isDarkMode) ...[
            _buildGlow(primaryColor.withAlpha(20), const Offset(-100, -100), 450),
            _buildGlow(Colors.blueAccent.withAlpha(10), const Offset(200, 200), 350),
          ] else ...[
            _buildGlow(primaryColor.withAlpha(15), const Offset(-100, -100), 500),
            _buildGlow(Colors.blueAccent.withAlpha(10), const Offset(300, 400), 400),
          ],
          
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _productStream,
            builder: (context, snapshot) {
              final allProducts = snapshot.data ?? [];
              final filteredMarketplace = allProducts.where((p) {
                final matchesSearch = p['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
                final matchesCategory = _selectedCategory == "All" || p['category'] == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              final isWaiting = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                cacheExtent: 1000, // Optimization: Pre-render content for smooth scrolling
                slivers: [
                  // --- CINEMATIC BRAND HEADER ---
                  SliverAppBar(
                    expandedHeight: 140,
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
                                Text("AURA", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w200, letterSpacing: 8, color: isDarkMode ? Colors.white : Colors.black)),
                                Text("MART", style: TextStyle(fontSize: 8, letterSpacing: 10, fontWeight: FontWeight.w900, color: primaryColor)),
                              ],
                            ),
                            _buildLogoutButton(isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- GREETING & STICKY GLASS SEARCH ---
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickySearchDelegate(
                      child: _buildSearchSection(isDarkMode, primaryColor, user),
                    ),
                  ),

                  // --- CATEGORY ORBS ---
                  SliverToBoxAdapter(child: _buildCategoryStrip(isDarkMode, primaryColor)),

                  // --- HERO GLASS CARD ---
                  if (_searchQuery.isEmpty)
                    SliverToBoxAdapter(child: _buildHeroSection(primaryColor)),

                  // --- SECTION: NEW ARRIVALS ---
                  if (allProducts.isNotEmpty && _searchQuery.isEmpty) ...[
                    _buildSectionHeaderSliver("New Arrivals", isDarkMode),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: allProducts.length > 5 ? 5 : allProducts.length,
                          itemBuilder: (context, index) => _buildModernHorizontalCard(allProducts[index], isDarkMode, index),
                        ),
                      ),
                    ),
                  ],

                  // --- MARKETPLACE MASONRY ---
                  _buildSectionHeaderSliver(_searchQuery.isEmpty ? "Discovery" : "Search Results", isDarkMode),
                  if (isWaiting)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ProductSkeleton(),
                          childCount: 4,
                        ),
                      ),
                    )
                  else if (filteredMarketplace.isEmpty)
                    const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(80), child: Text("No items found.", style: TextStyle(color: Colors.grey)))))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        itemBuilder: (context, index) => RepaintBoundary(
                          child: _buildUniqueProductCard(filteredMarketplace[index], isDarkMode, index)
                        ),
                        childCount: filteredMarketplace.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 150)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, Offset offset, double size) {
    return Positioned(left: offset.dx, top: offset.dy, child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent]))));
  }

  Widget _buildSearchSection(bool isDarkMode, Color primaryColor, User? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchQuery.isEmpty) ...[
            Text("Hello, ${user?.displayName?.split(' ').first ?? 'Friend'}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white38 : Colors.black38)),
            const SizedBox(height: 2),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Search your style...",
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26),
                    prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 22),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStrip(bool isDarkMode, Color primaryColor) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isSelected = _selectedCategory == cat['name'];
          final catColor = cat['color'] as Color;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isSelected ? 55 : 45,
                    width: isSelected ? 55 : 45,
                    decoration: BoxDecoration(
                      color: isSelected ? catColor : (isDarkMode ? Colors.white.withAlpha(13) : Colors.white),
                      shape: BoxShape.circle,
                      boxShadow: isSelected 
                        ? [BoxShadow(color: catColor.withAlpha(77), blurRadius: 10, offset: const Offset(0, 5))] 
                        : (isDarkMode ? [] : [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 5, offset: const Offset(0, 2))]),
                      border: Border.all(color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white10 : Colors.black12)),
                    ),
                    child: Icon(cat['icon'], size: isSelected ? 22 : 18, color: isSelected ? Colors.white : (isDarkMode ? Colors.white38 : catColor.withAlpha(150))),
                  ),
                  const SizedBox(height: 8),
                  Text(cat['name'], style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? catColor : (isDarkMode ? Colors.white38 : Colors.black45))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: const DecorationImage(image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1000"), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: LinearGradient(begin: Alignment.bottomRight, colors: [Colors.black.withAlpha(178), Colors.transparent])),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SEASONAL", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 4)),
              const Text("The Art of\nMinimalism", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w100, height: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHorizontalCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product))),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 15, bottom: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(8) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDarkMode ? 51 : 13), blurRadius: 15, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), 
                child: Hero(
                  tag: 'prod_${product['id']}_horiz',
                  child: CachedNetworkImage(
                    imageUrl: product['image'] ?? '', 
                    fit: BoxFit.cover, 
                    width: double.infinity,
                    memCacheWidth: 400, // Optimization: Reduce memory usage
                  )
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(product['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          Text(" 4.5", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                  Text("\$${product['price']}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniqueProductCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    bool isTall = index % 3 == 0;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(5) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(13)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25), 
                  child: Hero(
                    tag: 'prod_${product['id']}',
                    child: CachedNetworkImage(
                      imageUrl: product['image'] ?? '', 
                      fit: BoxFit.cover, 
                      width: double.infinity, 
                      height: isTall ? 240 : 180,
                      memCacheHeight: isTall ? 600 : 400, // Optimization: Memory efficiency
                    )
                  )
                ),
                Positioned(top: 10, right: 10, child: _buildWishlistBtn(product)),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                        Text(" 4.8", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$${product['price']}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)),
                      GestureDetector(
                        onTap: () async { 
                          try {
                            await AuraCartService.addToCart(product); 
                            Fluttertoast.showToast(msg: "Added to Bag"); 
                          } catch (e) {
                            Fluttertoast.showToast(msg: e.toString().replaceAll("Exception: ", ""));
                          }
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
      ),
    );
  }


  Widget _buildSectionHeaderSliver(String title, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 40, 25, 15),
        child: Row(children: [Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4, color: isDarkMode ? Colors.white24 : Colors.black26)), const SizedBox(width: 10), Expanded(child: Divider(color: isDarkMode ? Colors.white10 : Colors.black12))]),
      ),
    );
  }

  Widget _buildWishlistBtn(Map<String, dynamic> product) {
    return StreamBuilder<bool>(
      stream: AuraWishlistService.isInWishlistStream(product),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => AuraWishlistService.toggleWishlist(product),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(padding: const EdgeInsets.all(8), color: Colors.white.withAlpha(51), child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 16, color: isFav ? Colors.redAccent : Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(bool isDarkMode) {
    return Container(decoration: BoxDecoration(color: isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8), borderRadius: BorderRadius.circular(15)), child: IconButton(onPressed: () async { await FirebaseAuth.instance.signOut(); if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false); }, icon: Icon(Icons.logout_rounded, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87)));
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickySearchDelegate({required this.child});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: shrinkOffset > 20 ? 0.9 : 1.0), child: child);
  }
  @override
  double get maxExtent => 100;
  @override
  double get minExtent => 100;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
