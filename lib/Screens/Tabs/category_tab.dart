import 'package:aura_mart/screens/login_screen.dart';
import 'package:aura_mart/screens/products/eloria_category_products_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Fashion', 
      'icon': Icons.checkroom_rounded, 
      'color': Colors.pink,
      'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Mobiles', 
      'icon': Icons.smartphone_rounded, 
      'color': Colors.blue,
      'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Electronics', 
      'icon': Icons.bolt_rounded, 
      'color': Colors.amber,
      'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Home', 
      'icon': Icons.home_rounded, 
      'color': Colors.green,
      'image': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Beauty', 
      'icon': Icons.auto_awesome_rounded, 
      'color': Colors.purple,
      'image': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Toys', 
      'icon': Icons.smart_toy_rounded, 
      'color': Colors.orange,
      'image': 'https://images.unsplash.com/photo-1531323385165-27a1753272e2?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Sports', 
      'icon': Icons.sports_tennis_rounded, 
      'color': Colors.teal,
      'image': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Books', 
      'icon': Icons.auto_stories_rounded, 
      'color': Colors.brown,
      'image': 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?q=80&w=500&auto=format&fit=crop'
    },
    {
      'name': 'Appliances', 
      'icon': Icons.kitchen_rounded, 
      'color': Colors.cyan,
      'image': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=500&auto=format&fit=crop'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filteredCategories = _categories
        .where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF08080A) : const Color(0xFFFBFBFF),
      body: Stack(
        children: [
          // --- DYNAMIC BACKGROUND GLOW ---
          if (isDarkMode) ...[
            _buildAmbientGlow(Colors.deepPurple.withOpacity(0.1), const Offset(-100, -100), 400),
            _buildAmbientGlow(Colors.blue.withOpacity(0.05), const Offset(200, 200), 300),
          ],

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- CINEMATIC HEADER ---
              SliverAppBar(
                expandedHeight: 180,
                collapsedHeight: 80,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: CircleAvatar(
                            radius: 120,
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 80, 25, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AURA",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: 10,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                "MART",
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  ),
                ],
              ),

              // --- STICKY SEARCH BAR ---
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchDelegate(
                  child: _buildSearchSection(isDarkMode, primaryColor),
                ),
              ),

              // --- CATEGORY GRID ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                sliver: filteredCategories.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Text("No categories found.", style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildModernCategoryCard(filteredCategories[index], isDarkMode, primaryColor),
                          childCount: filteredCategories.length,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, Offset offset, double size) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }

  Widget _buildSearchSection(bool isDarkMode, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: "Search categories...",
                hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26),
                prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCategoryCard(Map<String, dynamic> cat, bool isDarkMode, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              categoryName: cat['name'],
              categoryColor: cat['color'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: CachedNetworkImageProvider(cat['image']),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'], size: 20, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                cat['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "DISCOVER",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickySearchDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    bool isScrolled = shrinkOffset > 20;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(isScrolled ? 0.9 : 1.0),
      child: child,
    );
  }

  @override
  double get maxExtent => 75;
  @override
  double get minExtent => 75;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
