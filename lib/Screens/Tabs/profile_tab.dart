import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura_mart/Screens/LoginScreen.dart';
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
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.displayName ?? 'User Name',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'email@example.com',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                _buildProfileOption(Icons.shopping_bag, 'My Orders', isDarkMode, onTap: () {
                  Fluttertoast.showToast(msg: "Order history coming soon!");
                }),
                _buildProfileOption(Icons.favorite, 'Wishlist', isDarkMode, onTap: () {
                  Fluttertoast.showToast(msg: "Your wishlist is empty");
                }),
                _buildProfileOption(Icons.location_on, 'Shipping Address', isDarkMode, onTap: () {
                  Fluttertoast.showToast(msg: "Address management coming soon!");
                }),
                _buildProfileOption(Icons.payment, 'Payment Methods', isDarkMode, onTap: () {
                  Fluttertoast.showToast(msg: "Secure payments coming soon!");
                }),
                const Divider(),
                _buildProfileOption(Icons.logout, 'Logout', isDarkMode, color: Colors.red, onTap: () async {
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
      leading: Icon(icon, color: color ?? Colors.deepPurple),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
