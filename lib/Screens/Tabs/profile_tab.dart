import 'package:aura_mart/screens/help_support_screen.dart';
import 'package:aura_mart/screens/my_orders_screen.dart';
import 'package:aura_mart/screens/payment_methods_screen.dart';
import 'package:aura_mart/screens/products/aura_wishlist_screen.dart';
import 'package:aura_mart/screens/seller/add_product_screen.dart';
import 'package:aura_mart/screens/settings_screen.dart';
import 'package:aura_mart/screens/shipping_address_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura_mart/screens/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Background Glows
          if (isDarkMode) ...[
            Positioned(right: -100, top: -100, child: _buildGlow(primaryColor.withAlpha(20), 450)),
            Positioned(left: -50, bottom: 100, child: _buildGlow(Colors.blueAccent.withAlpha(13), 350)),
          ] else ...[
            Positioned(right: -100, top: -100, child: _buildGlow(primaryColor.withAlpha(15), 500)),
            Positioned(left: -50, bottom: 100, child: _buildGlow(Colors.blueAccent.withAlpha(10), 400)),
          ],

          Column(
            children: [
              // Premium Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(30, 80, 30, 40),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MY PROFILE",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 8,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "YOUR PERSONAL SPACE",
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // User Identity Card
                      _buildUserIdentityCard(user, isDarkMode, primaryColor),
                      
                      const SizedBox(height: 35),
                      
                      // Quick Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard("12", "ORDERS", isDarkMode, primaryColor),
                          _buildStatCard("5", "WISHLIST", isDarkMode, primaryColor),
                          _buildStatCard("2", "OFFERS", isDarkMode, primaryColor),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Menu Sections
                      _buildMenuSection("ACCOUNT SETTINGS", [
                        _buildMenuOption(context, Icons.shopping_bag_outlined, 'My Orders', isDarkMode, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                        }),
                        _buildMenuOption(context, Icons.favorite_outline_rounded, 'Wishlist', isDarkMode, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                        }),
                        _buildMenuOption(context, Icons.location_on_outlined, 'Shipping Address', isDarkMode, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingAddressScreen()));
                        }),
                        _buildMenuOption(context, Icons.payment_outlined, 'Payment Methods', isDarkMode, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                        }),
                      ], isDarkMode),

                      const SizedBox(height: 25),

                      _buildMenuSection("SELLER CENTER", [
                        _buildMenuOption(context, Icons.storefront_outlined, 'Seller Hub - List Items', isDarkMode, color: Colors.blueAccent, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
                        }),
                      ], isDarkMode),

                      const SizedBox(height: 25),

                      _buildMenuSection("SUPPORT", [
                        _buildMenuOption(context, Icons.help_outline_rounded, 'Help & Support', isDarkMode, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                        }),
                        _buildMenuOption(context, Icons.settings_outlined, 'Settings', isDarkMode, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                        }),
                        _buildMenuOption(context, Icons.logout_rounded, 'Logout', isDarkMode, color: Colors.redAccent, onTap: () async {
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
                      ], isDarkMode),
                      
                      const SizedBox(height: 120), // Bottom spacing
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  Widget _buildUserIdentityCard(User? user, bool isDarkMode, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03)),
        boxShadow: [
          if (!isDarkMode) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withOpacity(0.5), width: 1),
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 10, color: Colors.white),
              )
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Aura User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'aura.user@example.com',
                  style: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black38, fontSize: 12, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined, size: 18, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, bool isDarkMode, Color primaryColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withAlpha(5) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(5)),
        boxShadow: [
          if (!isDarkMode) BoxShadow(color: primaryColor.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDarkMode ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> options, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 15),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2, 
              color: isDarkMode ? Colors.white24 : Colors.black26
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withAlpha(8) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withAlpha(5)),
            boxShadow: [
              if (!isDarkMode) BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(children: options),
        ),
      ],
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, bool isDarkMode, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? (isDarkMode ? Colors.white60 : Colors.black54), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: isDarkMode ? Colors.white10 : Colors.black12),
    );
  }
}
