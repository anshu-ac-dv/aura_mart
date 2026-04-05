import 'package:aura_mart/Screens/LoginScreen.dart';
import 'package:aura_mart/Services/CartService.dart';
import 'package:aura_mart/Services/WishlistService.dart';
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
  String _selectedCategory = "All";

  // Mock Products
  final List<Map<String, String>> _allProducts = [
    {'name': 'Wireless Headphones', 'price': '99', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Running Shoes', 'price': '75', 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Smart Watch', 'price': '150', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Coffee Maker', 'price': '45', 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1520970014086-2208d157c9e2?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Gaming Mouse', 'price': '30', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1527814050087-37a3d71ae69c?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Designer Bag', 'price': '120', 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Mechanical Keyboard', 'price': '85', 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Leather Wallet', 'price': '25', 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1627123424574-724758594e93?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Denim Jacket', 'price': '65', 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1576905341935-4ef24434494a?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Ceramic Vase', 'price': '35', 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1581783898377-1c85bf937427?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Yoga Mat', 'price': '20', 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Face Cream', 'price': '15', 'category': 'Beauty', 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Matte Lipstick', 'price': '12', 'category': 'Beauty', 'image': 'https://images.unsplash.com/photo-1586776977607-310e9c725c37?q=80&w=1000&auto=format&fit=crop'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Colors.blue},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
    {'name': 'Electronics', 'icon': Icons.bolt, 'color': Colors.amber},
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.orange},
    {'name': 'Beauty', 'icon': Icons.face, 'color': Colors.purple},
  ];

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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. BEAUTIFUL COLLAPSIBLE APPBAR
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
                      hintText: 'Search products, brands and more...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Location Bar
          SliverToBoxAdapter(child: _buildLocationBar(isDarkMode)),

          // 3. Horizontal Category List
          SliverToBoxAdapter(child: _buildHorizontalCategories(isDarkMode)),

          // 4. Promo Banner Slider
          SliverToBoxAdapter(child: _buildPromoSlider()),

          // 5. Section Headers and Horizontal Lists
          SliverToBoxAdapter(child: _buildSectionHeader("Deals of the Day", isDarkMode)),
          SliverToBoxAdapter(child: _buildHorizontalProductList(isDarkMode)),

          // 6. Featured Grid Section
          SliverToBoxAdapter(child: _buildSectionHeader("Suggested for You", isDarkMode)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10, 
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildAmazonProductCard(_filteredProducts[index], isDarkMode),
                childCount: _filteredProducts.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildLocationBar(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.deepPurple.withAlpha(20),
      child: const Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.deepPurple, size: 18),
          SizedBox(width: 5),
          Text(
            "Deliver to Anshu - New Delhi 110001",
            style: TextStyle(color: Colors.deepPurple, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.deepPurple, size: 18),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategories(bool isDarkMode) {
    return Container(
      height: 95,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: isSelected ? Colors.deepPurple : (cat['color'] as Color).withAlpha(30),
                    child: Icon(cat['icon'], color: isSelected ? Colors.white : cat['color']),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
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

  Widget _buildPromoSlider() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: PageView(
        children: [
          _buildBannerImage("https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000&auto=format&fit=crop"),
          _buildBannerImage("https://images.unsplash.com/photo-1607083206869-4c7672df7231?q=80&w=1000&auto=format&fit=crop"),
        ],
      ),
    );
  }

  Widget _buildBannerImage(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          const Text("See all", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(bool isDarkMode) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withAlpha(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(product['image']!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      ),
                      Positioned(
                        top: 5, right: 5,
                        child: StreamBuilder<bool>(
                          stream: WishlistService.isInWishlistStream(product['name']!),
                          builder: (context, snapshot) {
                            bool isFav = snapshot.data ?? false;
                            return CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white.withAlpha(200),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 16, color: Colors.red),
                                onPressed: () async {
                                  await WishlistService.toggleWishlist(product);
                                  Fluttertoast.showToast(msg: isFav ? "Removed from Wishlist" : "Added to Wishlist");
                                },
                              ),
                            );
                          }
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("\$${product['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                          InkWell(
                            onTap: () {
                              CartService.addToCart(product);
                              Fluttertoast.showToast(msg: "Added to cart");
                            },
                            child: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.deepPurple),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmazonProductCard(Map<String, String> product, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(product['image']!, fit: BoxFit.cover, width: double.infinity),
                ),
                Positioned(
                  top: 5, right: 5,
                  child: StreamBuilder<bool>(
                    stream: WishlistService.isInWishlistStream(product['name']!),
                    builder: (context, snapshot) {
                      bool isFav = snapshot.data ?? false;
                      return CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white.withAlpha(200),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 18, color: Colors.red),
                          onPressed: () async {
                            await WishlistService.toggleWishlist(product);
                            Fluttertoast.showToast(msg: isFav ? "Removed from Wishlist" : "Added to Wishlist");
                          },
                        ),
                      );
                    }
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text("\$${product['price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 5),
                    Text("\$${(double.tryParse(product['price']!) ?? 0) + 20}", 
                      style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      CartService.addToCart(product);
                      Fluttertoast.showToast(msg: "Added to cart");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: const Text("Add to Cart", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
