import 'package:flutter/material.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  // Mock Category Data with refined icons and branding
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electronics', 'icon': Icons.bolt_rounded, 'color': Colors.blue, 'items': '120 Items'},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Colors.pink, 'items': '450 Items'},
    {'name': 'Home', 'icon': Icons.home_rounded, 'color': Colors.green, 'items': '80 Items'},
    {'name': 'Toys', 'icon': Icons.smart_toy_rounded, 'color': Colors.orange, 'items': '210 Items'},
    {'name': 'Beauty', 'icon': Icons.face_retouching_natural_rounded, 'color': Colors.purple, 'items': '150 Items'},
    {'name': 'Sports', 'icon': Icons.sports_tennis_rounded, 'color': Colors.teal, 'items': '95 Items'},
    {'name': 'Accessories', 'icon': Icons.watch_rounded, 'color': Colors.indigo, 'items': '180 Items'},
    {'name': 'Books', 'icon': Icons.auto_stories_rounded, 'color': Colors.deepOrange, 'items': '320 Items'},
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- UNIQUE GLASSMORPHIC SLIVER HEADER ---
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Discover',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Search Bar positioned via PreferredSize
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900]?.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Find your vibe...',
                      hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.deepPurple),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- MODERN BENTO-STYLE GRID ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final filtered = _categories
                      .where((c) => c['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                  
                  if (index >= filtered.length) return null;
                  
                  final cat = filtered[index];
                  return _buildPremiumCategoryCard(cat, isDarkMode);
                },
                childCount: _categories
                    .where((c) => c['name']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCategoryCard(Map<String, dynamic> cat, bool isDarkMode) {
    Color baseColor = cat['color'];
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          // Abstract Background Shape
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: baseColor.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with Custom Glow
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [baseColor.withOpacity(0.2), baseColor.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat['icon'],
                    size: 38,
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  cat['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Item Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cat['items'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: baseColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Interactive Ripple Effect
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(30),
                splashColor: baseColor.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
