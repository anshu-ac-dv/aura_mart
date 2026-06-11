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
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Colors.indigo},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Colors.pinkAccent},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded, 'color': Colors.orangeAccent},
    {'name': 'Home', 'icon': Icons.home_filled, 'color': Colors.teal},
    {'name': 'Beauty', 'icon': Icons.auto_awesome_rounded, 'color': Colors.purpleAccent},
    {'name': 'Mobiles', 'icon': Icons.smartphone_rounded, 'color': Colors.blueAccent},
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- AMBIENT MESH BACKGROUND ---
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: isDarkMode 
                    ? [primaryColor.withAlpha(40), Colors.transparent] 
                    : [primaryColor.withAlpha(20), Colors.transparent],
                ),
              ),
            ),
          ),
          
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
                slivers: [
                  // --- PREMIUM BRAND HEADER ---
                  SliverAppBar(
                    expandedHeight: 120,
                    collapsedHeight: 70,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.fromLTRB(25, 50, 25, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text("AURA", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200, letterSpacing: 6, color: isDarkMode ? Colors.white : Colors.black)),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(4)),
                                      child: const Text("PRO", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                Text("LUXURY MARKETPLACE", style: TextStyle(fontSize: 7, letterSpacing: 4, fontWeight: FontWeight.w900, color: primaryColor.withAlpha(180))),
                              ],
                            ),
                            _buildTopActions(isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- SEARCH BAR SECTION ---
                  SliverToBoxAdapter(
                    child: _buildSearchSection(isDarkMode, primaryColor, user),
                  ),

                  // --- CATEGORY CHIPS ---
                  SliverToBoxAdapter(child: _buildCategoryStrip(isDarkMode, primaryColor)),

                  // --- PROMO HERO ---
                  if (_searchQuery.isEmpty)
                    SliverToBoxAdapter(child: _buildHeroSection(primaryColor)),

                  // --- HORIZONTAL DISCOVERY ---
                  if (allProducts.isNotEmpty && _searchQuery.isEmpty) ...[
                    _buildSectionHeaderSliver("New In", isDarkMode),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: allProducts.length > 5 ? 5 : allProducts.length,
                          itemBuilder: (context, index) => _buildModernHorizontalCard(allProducts[index], isDarkMode, index),
                        ),
                      ),
                    ),
                  ],

                  // --- MASONRY GRID ---
                  _buildSectionHeaderSliver(_searchQuery.isEmpty ? "Curated for you" : "Results for \"$_searchQuery\"", isDarkMode),
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
                    const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(80), child: Text("Nothing matches your search.", style: TextStyle(color: Colors.grey)))))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        itemBuilder: (context, index) => _buildUniqueProductCard(filteredMarketplace[index], isDarkMode, index),
                        childCount: filteredMarketplace.length,
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

  Widget _buildTopActions(bool isDarkMode) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withAlpha(15) : Colors.black.withAlpha(5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_rounded, size: 22, color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.withAlpha(50),
            child: const Icon(Icons.person_outline_rounded, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isDarkMode, Color primaryColor, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchQuery.isEmpty) ...[
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w300),
                children: [
                  const TextSpan(text: "Welcome back, "),
                  TextSpan(text: user?.displayName?.split(' ').first ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(10)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Search collections...",
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
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isSelected = _selectedCategory == cat['name'];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? (isDarkMode ? Colors.white : Colors.black) : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white10 : Colors.black12)),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Icon(cat['icon'], size: 16, color: isSelected ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white38 : Colors.black38)),
                  const SizedBox(width: 8),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white38 : Colors.black45)
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

  Widget _buildHeroSection(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: const DecorationImage(
            image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [Colors.black.withAlpha(200), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: const Text("LIMITED", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 8),
              const Text("Elevated Basics", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: 2)),
              Text("Up to 40% OFF", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
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
        width: 180,
        margin: const EdgeInsets.only(left: 15, bottom: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
                child: Hero(
                  tag: 'prod_${product['id']}_horiz',
                  child: CachedNetworkImage(imageUrl: product['image'] ?? '', fit: BoxFit.cover, width: double.infinity)
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1),
                  const SizedBox(height: 4),
                  Text("\$${product['price']}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniqueProductCard(Map<String, dynamic> product, bool isDarkMode, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), 
                child: Hero(
                  tag: 'prod_${product['id']}',
                  child: CachedNetworkImage(
                    imageUrl: product['image'] ?? '', 
                    fit: BoxFit.cover, 
                    width: double.infinity, 
                    height: index % 3 == 0 ? 250 : 200,
                  )
                )
              ),
              Positioned(top: 10, right: 10, child: _buildWishlistBtn(product)),
              Positioned(
                bottom: 10, 
                right: 10, 
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await AuraCartService.addToCart(product);
                      Fluttertoast.showToast(msg: "Added to Bag");
                    } catch (e) {
                      Fluttertoast.showToast(msg: e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Icon(Icons.add_shopping_cart_rounded, size: 16, color: Theme.of(context).primaryColor),
                  ),
                )
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1),
                Text("\$${product['price']}", style: TextStyle(color: Theme.of(context).primaryColor.withAlpha(200), fontWeight: FontWeight.w800, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderSliver(String title, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 30, 25, 15),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Icon(Icons.arrow_forward_rounded, size: 16, color: isDarkMode ? Colors.white24 : Colors.black26),
          ],
        ),
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
          child: Container(
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: Colors.white.withAlpha(180), shape: BoxShape.circle),
            child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 16, color: isFav ? Colors.redAccent : Colors.black54)
          ),
        );
      },
    );
  }
}
