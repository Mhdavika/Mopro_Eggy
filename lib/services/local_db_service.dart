import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dummy_data.dart';
import '../models/menu_item.dart';

class LocalDbService {
  static const String _keyOrders = 'kantin_bu_sari_orders';
  static const String _keyWallet = 'kantin_bu_sari_wallet';
  static const String _keyFavorites = 'kantin_bu_sari_favorites';

  static LocalDbService? _instance;
  static LocalDbService get instance => _instance ??= LocalDbService._();

  LocalDbService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Seed initial dummy data jika database lokal masih kosong pertama kali
    if (!_prefs!.containsKey(_keyOrders)) {
      await _seedInitialOrders();
    }
    if (!_prefs!.containsKey(_keyWallet)) {
      await _prefs!.setInt(_keyWallet, 45000);
    }
  }

  Future<void> _seedInitialOrders() async {
    final list = DummyData.orderHistories.map((o) {
      return {
        'orderId': o.orderId,
        'orderDate': o.orderDate.toIso8601String(),
        'itemNames': o.itemNames,
        'totalAmount': o.totalAmount,
        'status': o.status,
        'tableNumber': o.tableNumber,
      };
    }).toList();
    await _prefs!.setString(_keyOrders, jsonEncode(list));
  }

  // --- RIWAYAT PESANAN (ORDERS) ---
  Future<List<OrderHistory>> getOrders() async {
    await init();
    final jsonStr = _prefs!.getString(_keyOrders);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) {
        return OrderHistory(
          orderId: item['orderId'] as String,
          orderDate: DateTime.tryParse(item['orderDate'] as String) ?? DateTime.now(),
          itemNames: List<String>.from(item['itemNames'] as List),
          totalAmount: (item['totalAmount'] as num).toInt(),
          status: item['status'] as String,
          tableNumber: item['tableNumber'] as String,
        );
      }).toList();
    } catch (e) {
      return List.from(DummyData.orderHistories);
    }
  }

  Future<void> saveOrder(OrderHistory newOrder) async {
    await init();
    final orders = await getOrders();
    // Taruh pesanan baru di urutan paling atas
    orders.insert(0, newOrder);

    final list = orders.map((o) {
      return {
        'orderId': o.orderId,
        'orderDate': o.orderDate.toIso8601String(),
        'itemNames': o.itemNames,
        'totalAmount': o.totalAmount,
        'status': o.status,
        'tableNumber': o.tableNumber,
      };
    }).toList();

    await _prefs!.setString(_keyOrders, jsonEncode(list));
  }

  // --- SALDO LABKOM PAY ---
  Future<int> getWalletBalance() async {
    await init();
    return _prefs!.getInt(_keyWallet) ?? 45000;
  }

  Future<void> updateWalletBalance(int newBalance) async {
    await init();
    await _prefs!.setInt(_keyWallet, newBalance);
  }

  // --- MENU FAVORIT ---
  Future<Set<String>> getFavorites() async {
    await init();
    final list = _prefs!.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  Future<bool> toggleFavorite(String menuId) async {
    await init();
    final favs = (await getFavorites()).toList();
    bool isNowFav;
    if (favs.contains(menuId)) {
      favs.remove(menuId);
      isNowFav = false;
    } else {
      favs.add(menuId);
      isNowFav = true;
    }
    await _prefs!.setStringList(_keyFavorites, favs);
    return isNowFav;
  }

  Future<bool> isFavorite(String menuId) async {
    await init();
    final favs = _prefs!.getStringList(_keyFavorites) ?? [];
    return favs.contains(menuId);
  }

  // Reset database untuk testing
  Future<void> resetDatabase() async {
    await init();
    await _prefs!.remove(_keyOrders);
    await _prefs!.remove(_keyWallet);
    await _prefs!.remove(_keyFavorites);
    await _seedInitialOrders();
    await _prefs!.setInt(_keyWallet, 45000);
  }
}
