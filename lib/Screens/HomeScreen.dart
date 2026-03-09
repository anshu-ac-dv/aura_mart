import 'package:aura_mart/Screens/Tabs/cart_tab.dart';
import 'package:aura_mart/Screens/Tabs/category_tab.dart';
import 'package:aura_mart/Screens/Tabs/dashboard_tab.dart';
import 'package:aura_mart/Screens/Tabs/profile_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardTab(),
    CategoryTab(),
    CartTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Aura Mart', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            )
          : AppBar(
              title: Text(_getAppBarTitle()),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Categories';
      case 2:
        return 'My Cart';
      case 3:
        return 'My Profile';
      default:
        return 'Aura Mart';
    }
  }
}
