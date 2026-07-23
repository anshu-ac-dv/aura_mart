import 'package:aura_mart/core_services/theme_service.dart';
import 'package:aura_mart/features/products/domain/entities/product_entity.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_bloc.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_event.dart';
import 'package:aura_mart/features/products/presentation/bloc/product_state.dart';
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

  final List<Map<String, String>> _banners = [
    {
      'title': 'Premium Fashion',
      'subtitle': 'Up to 50% Off',
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop',
    },
    {
      'title': 'New Electronics',
      'subtitle': 'Latest Tech Gadgets',
      'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=800&auto=format&fit=crop',
    },
    {
      'title': 'Home Decor',
      'subtitle': 'Modern & Elegant',
      'image': 'https://images.unsplash.com/photo-1513519245088-0e12902e35a6?w=800&auto=format&fit=crop',
    },
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

  int _getColumnCount(double width) {
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final columnCount = _getColumnCount(size.width);
    final horizontalPadding = size.width > 600 ? 40.0 : 20.0;

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
              // --- PREMIUM APP BAR ---
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: theme.primaryColor,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.0,
                  titlePadding: EdgeInsets.zero,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withAlpha(200),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 60, horizontalPadding, 0),
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
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            _buildThemeToggle(isDarkMode),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Welcome, ${user?.displayName?.split(' ').first ?? 'Guest'}",
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- SEARCH SECTION ---
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -35),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: FadeInAnimation(
                      delay: 200,
                      child: Container(
                        height: 65,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDarkMode ? 100 : 20),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: theme.primaryColor, size: 28),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (v) => setState(() => _searchQuery = v),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: "Search premium products...",
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.white30 : Colors.black38,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 1.5,
                              color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.tune_rounded, color: theme.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- PROMOTIONAL BANNER ---
              if (_searchQuery.isEmpty && _selectedCategory == "All")
                SliverToBoxAdapter(
                  child: FadeInAnimation(
                    delay: 300,
                    child: _buildBannerCarousel(size.width, horizontalPadding),
                  ),
                ),

              // --- CATEGORIES ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: FadeInAnimation(
                    delay: 400,
                    child: SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          bool isSelected = _selectedCategory == cat['name'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              avatar: Icon(
                                cat['icon'],
                                size: 18,
                                color: isSelected ? Colors.white : theme.primaryColor,
                              ),
                              label: Text(cat['name']),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() => _selectedCategory = cat['name']);
                              },
                              backgroundColor: isDarkMode ? Colors.white.withAlpha(10) : Colors.grey.shade100,
                              selectedColor: theme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white10 : Colors.transparent),
                                ),
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

              // --- SECTION TITLE ---
              if (filteredMarketplace.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 20),
                    child: const Text(
                      "Our Collection",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

              // --- PRODUCT GRID ---
              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 100),
                sliver: isWaiting
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnCount,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ProductSkeleton(),
                          childCount: 6,
                        ),
                      )
                    : filteredMarketplace.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withAlpha(100)),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "No products found",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columnCount,
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

  Widget _buildBannerCarousel(double width, double padding) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: _banners.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Container(
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(banner['image']!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(80),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    banner['subtitle']!,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildThemeToggle(bool isDarkMode) {
    return GestureDetector(
      onTap: () => ThemeService.instance.toggleTheme(!isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withAlpha(60), width: 1),
        ),
        child: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
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
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDarkMode ? 60 : 8),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    child: Hero(
                      tag: 'prod_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildWishlistBtn(pMap),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartBloc>().add(CartItemAdded(pMap));
                          Fluttertoast.showToast(msg: "Added to Cart");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: Colors.white,
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
