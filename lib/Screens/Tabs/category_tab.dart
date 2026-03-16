import 'package:aura_mart/Screens/LoginScreen.dart';
import 'package:aura_mart/Screens/Products/CategoryProductsScreen.dart'; // Ensure filename matches your project
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Refined Category Data
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Colors.pink},
    {'name': 'Mobiles', 'icon': Icons.smartphone_rounded, 'color': Colors.blue},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    {'name': 'Home', 'icon': Icons.home_rounded, 'color': Colors.green},
    {'name': 'Beauty', 'icon': Icons.face_retouching_natural_rounded, 'color': Colors.purple},
    {'name': 'Toys', 'icon': Icons.smart_toy_rounded, 'color': Colors.orange},
    {'name': 'Sports', 'icon': Icons.sports_tennis_rounded, 'color': Colors.teal},
    {'name': 'Books', 'icon': Icons.auto_stories_rounded, 'color': Colors.brown},
    {'name': 'Appliances', 'icon': Icons.kitchen_rounded, 'color': Colors.cyan},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filteredCategories = _categories
        .where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. BRANDED COLLAPSIBLE APPBAR
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: Colors.deepPurple,
            elevation: 0,
            title: const Text(
              "AURA MART",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 22),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (r) => false
                    );
                  }
                },
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search all categories...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. CATEGORY GRID
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: filteredCategories.isEmpty
                ? const SliverToBoxAdapter(
              child: Center(child: Text("No categories found")),
            )
                : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 25,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final cat = filteredCategories[index];
                  return _buildCategoryItem(cat, isDarkMode);
                },
                childCount: filteredCategories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat, bool isDarkMode) {
    return InkWell(
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
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  cat['icon'],
                  size: 32,
                  color: cat['color'],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cat['name'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}