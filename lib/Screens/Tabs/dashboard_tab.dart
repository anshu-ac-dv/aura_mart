import 'package:aura_mart/core_services/theme_service.dart';
import 'package:aura_mart/features/products/domain/entities/product_entity.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_bloc.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_event.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_state.dart';
import 'package:aura_mart/screens/login_screen.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aura_mart/features/cart/presentation/bloc/cart_event.dart';
import 'package:aura_mart/core_services/wishlist_service.dart';
import 'package:aura_mart/screens/products/product_details_screen.dart';
import 'package:aura_mart/widgets/aura_animations.dart';
import 'package:aura_mart/widgets/aura_skeletons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'name': 'Electronics', 'icon': Icons.bolt_rounded},
    {'name': 'Home', 'icon': Icons.home_filled},
    {'name': 'Beauty', 'icon': Icons.auto_awesome_rounded},
    {'name': 'Mobiles', 'icon': Icons.smartphone_rounded},
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductsFetched());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final allProducts = state is ProductLoaded ? state.products : [];
          final filteredMarketplace = allProducts.where((p) {
            final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedCategory == "All" || p.category == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          final isWaiting = state is ProductLoading;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- VIBRANT APP BAR & HEADER ---
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: theme.primaryColor,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: _selectedIndex == 0 // Since it's a tab, we use a simple text or nothing when expanded
                    ? null 
                    : const Text("Aura Mart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(25, 60, 25, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Aura Mart",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            _buildThemeToggle(isDarkMode),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome, ${user?.displayName?.split(' ').first ?? 'Guest'}",
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (_searchQuery.isNotEmpty) _buildThemeToggle(isDarkMode),
                  const SizedBox(width: 10),
                ],
              ),

              // --- SEARCH SECTION (OVERLAPPING) ---
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeInAnimation(
                      delay: 200,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDarkMode ? 50 : 10),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- CATEGORIES ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 20),
                  child: FadeInAnimation(
                    delay: 400,
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          bool isSelected = _selectedCategory == cat['name'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(cat['name']),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() => _selectedCategory = cat['name']);
                              },
                              selectedColor: theme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // --- PRODUCT GRID ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: isWaiting
                    ? SliverGrid(
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
                      )
                    : filteredMarketplace.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Text("No products found"),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => FadeInAnimation(
                                delay: 100 + (index * 50),
                                child: _buildModernProductCard(filteredMarketplace[index]),
                              ),
                              childCount: filteredMarketplace.length,
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeToggle(bool isDarkMode) {
    return GestureDetector(
      onTap: () => ThemeService.instance.toggleTheme(!isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildModernProductCard(ProductEntity product) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final pMap = _entityToMap(product);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(product: pMap),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDarkMode ? 50 : 5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Hero(
                      tag: 'prod_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildWishlistBtn(pMap),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price}",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartBloc>().add(CartItemAdded(pMap));
                          Fluttertoast.showToast(msg: "Added to Cart");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: theme.primaryColor,
                            size: 18,
                          ),
                        ),
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

  Widget _buildWishlistBtn(Map<String, dynamic> pMap) {
    return StreamBuilder<bool>(
      stream: AuraWishlistService.isInWishlistStream(pMap),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => AuraWishlistService.toggleWishlist(pMap),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isFav ? Colors.redAccent : Colors.black54,
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _entityToMap(ProductEntity p) {
    return {
      'id': p.id,
      'name': p.name,
      'price': p.price,
      'image': p.image,
      'category': p.category,
      'description': p.description,
      'sellerId': p.sellerId,
      'sellerName': p.sellerName,
    };
  }
}

  Widget _buildSimpleProductCard(ProductEntity product) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pMap = _entityToMap(product);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(product: pMap),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Hero(
                      tag: 'prod_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildWishlistBtn(pMap),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartBloc>().add(CartItemAdded(pMap));
                          Fluttertoast.showToast(msg: "Added to Bag");
                        },
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
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

  Widget _buildWishlistBtn(Map<String, dynamic> pMap) {
    return StreamBuilder<bool>(
      stream: AuraWishlistService.isInWishlistStream(pMap),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => AuraWishlistService.toggleWishlist(pMap),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isFav ? Colors.redAccent : Colors.white,
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _entityToMap(ProductEntity p) {
    return {
      'id': p.id,
      'name': p.name,
      'price': p.price,
      'image': p.image,
      'category': p.category,
      'description': p.description,
      'sellerId': p.sellerId,
      'sellerName': p.sellerName,
    };
  }
}
