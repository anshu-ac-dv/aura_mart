import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura_mart/Screens/LoginScreen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(user?.displayName ?? 'User Name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user?.email ?? 'email@example.com', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          _buildProfileOption(Icons.shopping_bag, 'My Orders'),
          _buildProfileOption(Icons.favorite, 'Wishlist'),
          _buildProfileOption(Icons.location_on, 'Shipping Address'),
          _buildProfileOption(Icons.payment, 'Payment Methods'),
          const Divider(),
          _buildProfileOption(Icons.logout, 'Logout', color: Colors.red, onTap: () async {
            await FirebaseAuth.instance.signOut();
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
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.deepPurple),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
