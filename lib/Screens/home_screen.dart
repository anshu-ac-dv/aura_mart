import 'package:aura_mart/screens/tabs/cart_tab.dart';
import 'package:aura_mart/screens/tabs/category_tab.dart';
import 'package:aura_mart/screens/tabs/dashboard_tab.dart';
import 'package:aura_mart/screens/tabs/profile_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const [
    DashboardTab(),
    CategoryTab(),
    CartTab(),
    ProfileTab(),
  ];

  final List<IconData> _navIcons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.shopping_bag_rounded,
    Icons.person_rounded,
  ];

  final List<String> _navLabels = ['Home', 'Explore', 'Cart', 'Profile'];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.fromLTRB(
            isSmallScreen ? 10 : 20,
            0,
            isSmallScreen ? 10 : 20,
            25
        ),
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 5 : 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_navIcons.length, (index) {
            bool isSelected = _selectedIndex == index;
            double targetWidth = isSelected
                ? (isSmallScreen ? 90 : 110)
                : (isSmallScreen ? 50 : 60);

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: targetWidth,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _navIcons[index],
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white38 : Colors.grey[600]),
                      size: isSmallScreen ? 22 : 26,
                    ),
                    if (isSelected) ...[
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      Flexible(
                        child: Text(
                          _navLabels[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}