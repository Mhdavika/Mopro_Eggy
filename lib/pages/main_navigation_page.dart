import 'package:flutter/material.dart';
import 'history_page.dart';
import 'menu_list_page.dart';
import 'order_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MenuListPage(),
    OrderPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWeb = screenWidth >= 800;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (isDesktopOrWeb) {
      // Tampilan Responsif untuk Website / Laptop / Layar Lebar (NavigationRail)
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              extended: screenWidth >= 1100, // Tampilkan teks penuh jika layar > 1100px
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.restaurant, color: Colors.white, size: 26),
                    ),
                    if (screenWidth >= 1100) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Kantin Bu Sari',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Text(
                        'Gedung Maroon Labkom',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              indicatorColor: Colors.deepOrange.shade100,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu, color: Colors.deepOrange),
                  label: Text('Daftar Menu'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart, color: Colors.deepOrange),
                  label: Text('Keranjang Pesan'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long, color: Colors.deepOrange),
                  label: Text('Riwayat Order'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront, color: Colors.deepOrange),
                  label: Text('Info Kantin & Profil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    // Tampilan Responsif untuk Mobile / Smartphone (Bottom NavigationBar)
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: Colors.deepOrange.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: Colors.deepOrange),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Colors.deepOrange),
            label: 'Keranjang',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.deepOrange),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Colors.deepOrange),
            label: 'Info Kantin',
          ),
        ],
      ),
    );
  }
}
