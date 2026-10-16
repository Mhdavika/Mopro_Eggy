import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class CartService extends ChangeNotifier {
  static CartService? _instance;
  static CartService get instance => _instance ??= CartService._();

  CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  int get subtotal => _items.fold(0, (sum, i) => sum + i.itemPrice);

  void addItem({
    required MenuItem menu,
    int quantity = 1,
    String selectedSpiceLevel = '',
    List<MenuItemTopping> selectedToppings = const [],
    String specialNotes = '',
  }) {
    // Cari apakah item dengan menu, spice, dan topping yang sama sudah ada di keranjang
    final existingIndex = _items.indexWhere((item) =>
        item.menu.id == menu.id &&
        item.selectedSpiceLevel == selectedSpiceLevel &&
        _areToppingsEqual(item.selectedToppings, selectedToppings));

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
      if (specialNotes.isNotEmpty) {
        _items[existingIndex].specialNotes = specialNotes;
      }
    } else {
      _items.add(CartItem(
        menu: menu,
        quantity: quantity,
        selectedSpiceLevel: selectedSpiceLevel,
        selectedToppings: selectedToppings,
        specialNotes: specialNotes,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool _areToppingsEqual(List<MenuItemTopping> a, List<MenuItemTopping> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((t) => t.id).toSet();
    final bIds = b.map((t) => t.id).toSet();
    return aIds.containsAll(bIds);
  }
}
