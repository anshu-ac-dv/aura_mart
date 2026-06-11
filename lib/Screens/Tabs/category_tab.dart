import 'package:aura_mart/screens/login_screen.dart';
import 'package:aura_mart/screens/products/aura_category_products_screen.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- AMBIENT GLOW ---
          Positioned(
            right: -100,
            top: -100,
            child: CircleAvatar(radius: 200, backgroundColor: primaryColor.withAlpha(isDarkMode ? 20 : 10)),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- MATCHING BRAND HEADER ---
              SliverAppBar(
                expandedHeight: 120,
                collapsedHeight: 70,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(25, 50, 25, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("EXPLORE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200, letterSpacing: 6, color: isDarkMode ? Colors.white : Colors.black)),
                        Text("COLLECTIONS", style: TextStyle(fontSize: 7, letterSpacing: 4, fontWeight: FontWeight.w900, color: primaryColor.withAlpha(180))),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15, top: 10),
                    child: IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
                      },
                      icon: Icon(Icons.logout_rounded, color: isDarkMode ? Colors.white38 : Colors.black38, size: 20),
                    ),
                  ),
                ],
              ),

              // --- SEARCH SECTION ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(10)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: "Search categories...",
                            hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 14),
                            prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- CATEGORY LIST/GRID ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: filteredCategories.isEmpty
                    ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 100), child: Text("No categories found.", style: TextStyle(color: Colors.grey)))))
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.85,
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
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: CachedNetworkImageProvider(cat['image']),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                Colors.black.withAlpha(180),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat['name'].toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 2,
                color: cat['color'] as Color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
