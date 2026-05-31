import 'package:aura_mart/Screens/LoginScreen.dart';
import 'package:aura_mart/Services/CartService.dart';
import 'package:aura_mart/Services/WishlistService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _promoController = PageController();
  String _searchQuery = "";
  String _selectedCategory = "All";
  int _currentPromoPage = 0;
  
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 12, minutes: 30, seconds: 0);

  // Mock Products
  final List<Map<String, dynamic>> _allProducts = [
    {'name': 'Wireless Headphones', 'price': 99.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Running Shoes', 'price': 75.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Smart Watch', 'price': 150.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Coffee Maker', 'price': 45.0, 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1520970014086-2208d157c9e2?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Gaming Mouse', 'price': 30.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1527814050087-37a3d71ae69c?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Designer Bag', 'price': 120.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Mechanical Keyboard', 'price': 85.0, 'category': 'Electronics', 'image': 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Leather Wallet', 'price': 25.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1627123424574-724758594e93?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Denim Jacket', 'price': 65.0, 'category': 'Fashion', 'image': 'https://images.unsplash.com/photo-1576905341935-4ef24434494a?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Ceramic Vase', 'price': 35.0, 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1581783898377-1c85bf937427?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Yoga Mat', 'price': 20.0, 'category': 'Home', 'image': 'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Face Cream', 'price': 15.0, 'category': 'Beauty', 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=1000&auto=format&fit=crop'},
    {'name': 'Matte Lipstick', 'price': 12.0, 'category': 'Beauty', 'image': 'https://images.unsplash.com/photo-1586776977607-310e9c725c37?q=80&w=1000&auto=format&fit=crop'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': Colors.blue},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
    {'name': 'Electronics', 'icon': Icons.bolt, 'color': Colors.amber},
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.orange},
    {'name': 'Beauty', 'icon': Icons.face, 'color': Colors.purple},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch = p['name']!.toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || p['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. BEAUTIFUL COLLAPSIBLE APPBAR
          SliverAppBar(
            pinned: true,
            expandedHeight: isTablet ? 200 : 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withAlpha(20),
                      ),
                    ),
                  ],
                ),
              ),
              title: const Text(
                "AURA MART",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 15, bottom: 95),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 22),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()), 
                      (r) => false
                    );
                  }
                },
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(75),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10, 
                childAspectRatio: isTablet ? 0.85 : 0.75,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickActionMenu(context, isDarkMode);
        },
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        child: const Icon(Icons.bolt, color: Colors.white, size: 30),
      ),
    );
  }

  void _showQuickActionMenu(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(Icons.support_agent, "Support", Colors.orange),
                _buildQuickAction(Icons.local_offer, "Coupons", Colors.green),
                _buildQuickAction(Icons.track_changes, "Track", Colors.blue),
                _buildQuickAction(Icons.qr_code_scanner, "Scan", Colors.purple),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withAlpha(20),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLocationBar(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      color: Colors.deepPurple.withAlpha(15),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.deepPurple, size: 18),
          const SizedBox(width: 5),
          const Expanded(
            child: Text(
              "Deliver to Anshu - New Delhi 110001",
              style: TextStyle(color: Colors.deepPurple, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 25,
            width: 25,
            child: Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_jt7poy9k.json', // Simple delivery animation
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.keyboard_arrow_down, color: Colors.deepPurple, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategories(bool isDarkMode) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: Container(
              width: 85,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: isSelected ? Colors.deepPurple : (cat['color'] as Color).withAlpha(35),
                      child: Icon(cat['icon'], color: isSelected ? Colors.white : cat['color'], size: 22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.deepPurple : (isDarkMode ? Colors.white70 : Colors.black87),
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
    return Column(
      children: [
        Container(
          height: 170,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: PageView(
            controller: _promoController,
            onPageChanged: (index) {
              setState(() => _currentPromoPage = index);
            },
            children: [
              _buildBannerImage("https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000&auto=format&fit=crop"),
              _buildBannerImage("https://images.unsplash.com/photo-1607083206869-4c7672df7231?q=80&w=1000&auto=format&fit=crop"),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _currentPromoPage == index ? 16 : 8,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: _currentPromoPage == index ? Colors.deepPurple : Colors.grey.withAlpha(100),
            ),
          )),
        )
      ],
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
    String timeStr = "${_timeLeft.inHours.toString().padLeft(2, '0')}:${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}";
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
              if (title == "Deals of the Day") ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                  child: Text(timeStr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ]
            ],
          ),
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
                        child: CachedNetworkImage(
                          imageUrl: product['image']!.toString(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                        ),
                      ),
                      Positioned(
                        top: 5, right: 5,
                        child: StreamBuilder<bool>(
                          stream: WishlistService.isInWishlistStream(product['name']!.toString()),
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
                      Text(product['name']!.toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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

  Widget _buildAmazonProductCard(Map<String, dynamic> product, bool isDarkMode) {
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
                  child: CachedNetworkImage(
                    imageUrl: product['image']!.toString(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "20% OFF",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 5, right: 5,
                  child: StreamBuilder<bool>(
                    stream: WishlistService.isInWishlistStream(product['name']!),
                    builder: (context, snapshot) {
                      bool isFav = snapshot.data ?? false;
                      return CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white.withAlpha(220),
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
                    Text("\$${(product['price'] as num) + 20}",
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
