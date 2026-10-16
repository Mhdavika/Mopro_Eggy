import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/local_db_service.dart';
import '../utils/formatters.dart';
import 'history_page.dart';
import 'menu_list_page.dart';
import 'order_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;
  int _walletBalance = 45000;

  final List<Widget> _pages = const [
    MenuListPage(),
    OrderPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadWallet();
    CartService.instance.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadWallet() async {
    final bal = await LocalDbService.instance.getWalletBalance();
    if (mounted) setState(() => _walletBalance = bal);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWeb = screenWidth >= 800;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cartCount = CartService.instance.totalCount;

    if (isDesktopOrWeb) {
      // TAMPILAN WEB / LAPTOP PROFESIONAL
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // Top Web Navbar Header
            Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    children: [
                      // Brand Logo
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 0),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.restaurant, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kantin Bu Sari',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Maroon Labkom Canteen Web',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Navigation Tabs (Scrollable to prevent overflow)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildWebTab(0, 'Daftar Menu', Icons.restaurant_menu),
                              const SizedBox(width: 6),
                              _buildWebTab(1, 'Keranjang Pesanan', Icons.shopping_cart_outlined, badgeCount: cartCount),
                              const SizedBox(width: 6),
                              _buildWebTab(2, 'Riwayat Transaksi', Icons.receipt_long_outlined),
                              const SizedBox(width: 6),
                              _buildWebTab(3, 'Profil & Info', Icons.person_outline),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Saldo Labkom Pay Pill
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 3),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.deepOrange.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, size: 16, color: Colors.deepOrange),
                              const SizedBox(width: 6),
                              Text(
                                formatRupiah(_walletBalance),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Avatar Pill
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 3),
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.deepOrange.shade100,
                          child: const Icon(Icons.person, color: Colors.deepOrange, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Konten Tab Aktif
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

    // TAMPILAN MOBILE (BOTTOM NAVIGATION BAR)
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
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: Colors.deepOrange),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: Colors.deepOrange,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: Colors.deepOrange,
              child: const Icon(Icons.shopping_cart, color: Colors.deepOrange),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.deepOrange),
            label: 'Riwayat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.deepOrange),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildWebTab(int index, String label, IconData icon, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount'),
              backgroundColor: primaryColor,
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? primaryColor : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
