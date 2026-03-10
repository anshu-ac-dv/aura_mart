import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

// Tab for showing the main dashboard with search and featured products
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Logic: Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Logic: Mock product data (Usually comes from Firebase/API)
  final List<Map<String, String>> _allProducts = [
    {'name': 'Wireless Headphones', 'price': '\$99', 'category': 'Electronics'},
    {'name': 'Running Shoes', 'price': '\$75', 'category': 'Fashion'},
    {'name': 'Smart Watch', 'price': '\$150', 'category': 'Electronics'},
    {'name': 'Coffee Maker', 'price': '\$45', 'category': 'Home'},
    {'name': 'Gaming Mouse', 'price': '\$30', 'category': 'Electronics'},
    {'name': 'Designer Bag', 'price': '\$120', 'category': 'Fashion'},
  ];

  List<Map<String, String>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    return _allProducts
        .where((p) => p['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60,),
                Text(
                  'Aura Mart',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Welcome, ${user?.displayName?.toUpperCase() ?? 'User'}!',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'What are you looking for today?',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Search Logic Integration
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() { _searchQuery = ""; });
                          },
                        ) 
                      : null,
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Category List
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildCategoryItem(Icons.flash_on, 'Deals'),
                _buildCategoryItem(Icons.laptop, 'Electronics'),
                _buildCategoryItem(Icons.checkroom, 'Fashion'),
                _buildCategoryItem(Icons.home, 'Home'),
                _buildCategoryItem(Icons.toys, 'Toys'),
              ],
            ),
          ),
          
          // Products Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_filteredProducts.length} items',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Logic: Display filtered results or Empty message
          _filteredProducts.isEmpty 
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Text('No products found matching your search.'),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product['name']!, product['price']!);
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Logic: Category filtering could go here
              Fluttertoast.showToast(msg: "Filtered by $label");
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              child: Icon(icon, color: Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    const Icon(Icons.add_shopping_cart, size: 18, color: Colors.deepPurple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Added missing import

