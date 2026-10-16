class MenuItemTopping {
  final String id;
  final String name;
  final int price;

  const MenuItemTopping({
    required this.id,
    required this.name,
    required this.price,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final int? originalPrice;
  final double rating;
  final int reviewCount;
  final int prepTimeMinutes;
  final String description;
  final String imageUrl;
  final bool isPopular;
  final bool isPromo;
  final List<String> spiceLevels;
  final List<MenuItemTopping> availableToppings;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.prepTimeMinutes,
    required this.description,
    required this.imageUrl,
    this.isPopular = false,
    this.isPromo = false,
    this.spiceLevels = const [],
    this.availableToppings = const [],
  });
}

class CartItem {
  final MenuItem menu;
  int quantity;
  String selectedSpiceLevel;
  List<MenuItemTopping> selectedToppings;
  String specialNotes;

  CartItem({
    required this.menu,
    this.quantity = 1,
    this.selectedSpiceLevel = 'Tidak Pedas',
    this.selectedToppings = const [],
    this.specialNotes = '',
  });

  int get itemPrice {
    int toppingsTotal = selectedToppings.fold(0, (sum, t) => sum + t.price);
    return (menu.price + toppingsTotal) * quantity;
  }
}

class OrderHistory {
  final String orderId;
  final DateTime orderDate;
  final List<String> itemNames;
  final int totalAmount;
  final String status;
  final String tableNumber;

  const OrderHistory({
    required this.orderId,
    required this.orderDate,
    required this.itemNames,
    required this.totalAmount,
    required this.status,
    required this.tableNumber,
  });
}
