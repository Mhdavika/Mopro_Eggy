import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/menu_item.dart';
import '../services/local_db_service.dart';
import '../utils/formatters.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  String selectedCategory = 'Semua';
  String searchQuery = '';
  bool isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPromoIndex = 0;

  // Local Cart State untuk quick action
  final Map<String, int> _quickCart = {};
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await LocalDbService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteIds = favs;
      });
    }
  }

  Future<void> _toggleFavorite(MenuItem item) async {
    final isFav = await LocalDbService.instance.toggleFavorite(item.id);
    await _loadFavorites();
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1200),
        content: Text(
          isFav ? '${item.name} disimpan ke favorit!' : 'Dihapus dari favorit',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<MenuItem> get filteredMenu {
    return DummyData.menuList.where((item) {
      final matchesCategory =
          selectedCategory == 'Semua' || item.category == selectedCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get totalCartItems {
    return _quickCart.values.fold(0, (sum, count) => sum + count);
  }

  int get totalCartPrice {
    int total = 0;
    _quickCart.forEach((id, qty) {
      final menu = DummyData.menuList.firstWhere((m) => m.id == id);
      total += menu.price * qty;
    });
    return total;
  }

  void _addToCart(MenuItem item) {
    setState(() {
      _quickCart[item.id] = (_quickCart[item.id] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.deepOrange,
        content: Text('${item.name} ditambahkan ke pesanan!'),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Colors.white,
          onPressed: _goToCheckout,
        ),
      ),
    );
  }

  void _goToCheckout() {
    List<CartItem> items = [];
    if (_quickCart.isNotEmpty) {
      _quickCart.forEach((id, qty) {
        final menu = DummyData.menuList.firstWhere((m) => m.id == id);
        items.add(CartItem(
          menu: menu,
          quantity: qty,
          selectedSpiceLevel: menu.spiceLevels.isNotEmpty ? menu.spiceLevels.first : '',
        ));
      });
    } else {
      items = List.from(DummyData.sampleCart);
    }
    Navigator.pushNamed(context, '/pesan', arguments: items);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Kalkulasi kolom grid responsif untuk mobile, tablet, dan web/laptop
    int crossAxisCount;
    double childAspectRatio;
    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.68;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.72;
    } else if (screenWidth < 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    } else {
      crossAxisCount = 5;
      childAspectRatio = 0.78;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kantin Bu Sari',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Gedung Maroon Labkom • Buka (07.30 - 16.30)',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Riwayat Pesanan',
                  onPressed: () => Navigator.pushNamed(context, '/riwayat'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Profil & Info Kantin',
                  onPressed: () => Navigator.pushNamed(context, '/profil'),
                ),
                // Badge Icon Keranjang
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      tooltip: 'Keranjang Pesanan',
                      onPressed: _goToCheckout,
                    ),
                    if (totalCartItems > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$totalCartItems',
                            style: const TextStyle(
                              color: Colors.brown,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            slivers: [
              // 1. Search Bar
              SliverToBoxAdapter(
                child: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari ayam geprek, es teh, soto, mendoan...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // 2. Banner Promo Carousel
              if (searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: DummyData.promoBanners.length,
                          onPageChanged: (idx) {
                            setState(() => _currentPromoIndex = idx);
                          },
                          itemBuilder: (context, index) {
                            final banner = DummyData.promoBanners[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(banner['color'] as int),
                                    Colors.deepOrange.shade400,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'KODE PROMO: ${banner['code']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          banner['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          banner['subtitle'] as String,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.amber,
                                    size: 44,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Dots Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          DummyData.promoBanners.length,
                          (idx) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPromoIndex == idx ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPromoIndex == idx ? primaryColor : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Category Filter Chips & View Mode Switcher
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilihan Kategori Menu',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          // View switcher button
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isGridView ? Icons.view_list : Icons.grid_view,
                              color: primaryColor,
                            ),
                            tooltip: isGridView ? 'Ganti ke Tampilan List' : 'Ganti ke Tampilan Grid',
                            onPressed: () {
                              setState(() => isGridView = !isGridView);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: DummyData.categories.map((category) {
                            final isSelected = selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                selectedColor: primaryColor.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: isSelected ? primaryColor : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => selectedCategory = category);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Menampilkan ${filteredMenu.length} menu ${selectedCategory != "Semua" ? "di kategori $selectedCategory" : ""}:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Menu Items (Responsif Grid atau List)
              if (filteredMenu.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Menu "$searchQuery" tidak ditemukan',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isGridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredMenu[index];
                        final isFav = _favoriteIds.contains(item.id);
                        return _buildGridCard(item, primaryColor, isFav);
                      },
                      childCount: filteredMenu.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredMenu[index];
                        final isFav = _favoriteIds.contains(item.id);
                        return _buildListCard(item, primaryColor, isFav);
                      },
                      childCount: filteredMenu.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // 5. Floating Bottom Bar bila ada isi di keranjang
      bottomSheet: totalCartItems > 0
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalCartItems Menu Dipilih',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              formatRupiah(totalCartPrice),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _goToCheckout,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Lanjut Pesan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // Widget Card untuk Grid View
  Widget _buildGridCard(MenuItem item, Color primaryColor, bool isFav) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, '/detail', arguments: item);
          _loadFavorites();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Badges
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.deepOrange.shade100,
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 40, color: Colors.deepOrange),
                      ),
                    ),
                  ),
                  if (item.isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST SELLER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _toggleFavorite(item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '${item.rating}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        formatRupiah(item.price),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _addToCart(item),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Card untuk List View
  Widget _buildListCard(MenuItem item, Color primaryColor, bool isFav) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.8,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.pushNamed(context, '/detail', arguments: item);
          _loadFavorites();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 84,
                    height: 84,
                    color: Colors.deepOrange.shade100,
                    child: const Icon(Icons.fastfood, color: Colors.deepOrange),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        InkWell(
                          onTap: () => _toggleFavorite(item),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.redAccent : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          formatRupiah(item.price),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              '${item.rating} (${item.reviewCount})',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _addToCart(item),
                          child: const Text('+ Pesan', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
