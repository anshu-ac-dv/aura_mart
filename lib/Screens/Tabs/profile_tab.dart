import 'package:eloria_collection/screens/my_orders_screen.dart';
import 'package:eloria_collection/screens/payment_methods_screen.dart';
import 'package:eloria_collection/screens/products/aura_wishlist_screen.dart';
import 'package:eloria_collection/screens/seller/add_product_screen.dart';
import 'package:eloria_collection/screens/shipping_address_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eloria_collection/screens/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // --- PREMIUM HEADER ---
        Container(
          padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: const Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.deepPurple,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 15, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  user?.displayName ?? 'Eloria User',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'eloria.user@example.com',
                  style: const TextStyle(color: Colors.grey, letterSpacing: 1),
                ),
                const SizedBox(height: 25),
                
                // --- QUICK STATS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("12", "Orders", isDarkMode),
                    _buildStatCard("5", "Wishlist", isDarkMode),
                    _buildStatCard("2", "Coupons", isDarkMode),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                _buildProfileOption(Icons.shopping_bag_outlined, 'My Orders', isDarkMode, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                }),
                _buildProfileOption(Icons.favorite_outline, 'Wishlist', isDarkMode, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                }),
                _buildProfileOption(Icons.location_on_outlined, 'Shipping Address', isDarkMode, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingAddressScreen()));
                }),
                _buildProfileOption(Icons.payment_outlined, 'Payment Methods', isDarkMode, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                }),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),

                _buildProfileOption(Icons.storefront_outlined, 'Seller Hub - List Items', isDarkMode, color: Colors.blueAccent, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
                }),
                
                _buildProfileOption(Icons.help_outline, 'Help & Support', isDarkMode),
                _buildProfileOption(Icons.settings_outlined, 'Settings', isDarkMode),
                
                const SizedBox(height: 10),
                
                _buildProfileOption(Icons.logout, 'Logout', isDarkMode, color: Colors.redAccent, onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Fluttertoast.showToast(msg: "Logged out successfully");
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100), // Space for floating nav bar
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, bool isDarkMode, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.deepPurple).withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? Colors.deepPurple, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isDarkMode ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDarkMode ? Colors.white24 : Colors.black26),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String value, String label, bool isDarkMode) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode ? 50 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white60 : Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
