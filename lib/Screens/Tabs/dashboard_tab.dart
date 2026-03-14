import 'package:aura_mart/Screens/LoginScreen.dart';
import 'package:aura_mart/Services/CartService.dart';import 'package:aura_mart/Services/WishlistService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All"; // Logic: State for category filtering

  final List<Map<String, String>> _allProducts = [
    {'name': 'Wireless Headphones', 'price': '99', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Running Shoes', 'price': '75', 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Smart Watch', 'price': '150', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Coffee Maker', 'price': '45', 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1520970014086-2208d157c9e2?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Gaming Mouse', 'price': '30', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1527814050087-37a3d71ae69c?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Designer Bag', 'price': '120', 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=1000&auto=format&fit=crop'},
  ];

  // Logic: Combined Filtering (Search + Category)
  List<Map<String, String>> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch = p['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
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
    final user = FirebaseAuth.instance.currentUser;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user, isDarkMode),
          _buildCategorySection(isDarkMode),
          _buildProductGrid(isDarkMode),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildHeader(User? user, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aura Mart', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text('Hey, ${user?.displayName?.split(' ')[0] ?? 'Shopper'}!',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
                },
              )
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
              fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isDarkMode) {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Colors.blue},
      {'name': 'Electronics', 'icon': Icons.bolt, 'color': Colors.amber},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Home', 'icon': Icons.home_work, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
          child: Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              bool isSelected = _selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['name'] as String),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isSelected ? Colors.deepPurple : (cat['color'] as Color).withOpacity(0.1),
                        child: Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : cat['color'] as Color),
                      ),
                      const SizedBox(height: 8),
                      Text(cat['name'] as String, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.7,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: Image.network(product['image']!, fit: BoxFit.cover, width: double.infinity),
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: StreamBuilder<bool>(
                            stream: WishlistService.isInWishlistStream(product['name']!),
                            builder: (context, snapshot) {
                              bool isFav = snapshot.data ?? false;
                              return IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 18, color: Colors.red),
                                onPressed: () async => await WishlistService.toggleWishlist(product),
                              );
                            }
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name']!, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${product['price']}", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () {
                            CartService.addToCart(product);
                            Fluttertoast.showToast(msg: "${product['name']} added to cart");
                          },
                          child: const CircleAvatar(radius: 14, backgroundColor: Colors.deepPurple, child: Icon(Icons.add, color: Colors.white, size: 16)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}