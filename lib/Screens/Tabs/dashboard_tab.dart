import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text(
                  'Hello, ${user?.displayName ?? 'User'}!',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'What are you looking for today?',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Featured Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildProductCard('Product ${index + 1}', '\$${(index + 1) * 25}');
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
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Icon(icon, color: Colors.deepPurple),
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
