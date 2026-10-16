import '../models/menu_item.dart';

class DummyData {
  static const List<String> categories = [
    'Semua',
    'Makanan Utama',
    'Minuman Segar',
    'Snack & Cemilan',
    'Paket Hemat',
  ];

  static const List<MenuItemTopping> standardFoodToppings = [
    MenuItemTopping(id: 't1', name: 'Telur Mata Sapi / Dadar', price: 4000),
    MenuItemTopping(id: 't2', name: 'Nasi Putih Tambah', price: 3000),
    MenuItemTopping(id: 't3', name: 'Kerupuk Kaleng Renyah (2 pcs)', price: 2000),
    MenuItemTopping(id: 't4', name: 'Ekstra Sambal Pedas Nampol', price: 2500),
  ];

  static const List<MenuItemTopping> standardDrinkToppings = [
    MenuItemTopping(id: 'd1', name: 'Ekstra Es Batu Segar', price: 1000),
    MenuItemTopping(id: 'd2', name: 'Gula Aren Asli', price: 2000),
    MenuItemTopping(id: 'd3', name: 'Susu Kental Manis', price: 2500),
    MenuItemTopping(id: 'd4', name: 'Biji Selasih', price: 1500),
  ];

  static const List<MenuItem> menuList = [
    MenuItem(
      id: 'm1',
      name: 'Ayam Geprek Sambal Korek Bu Sari',
      category: 'Makanan Utama',
      price: 15000,
      originalPrice: 18000,
      rating: 4.9,
      reviewCount: 320,
      prepTimeMinutes: 10,
      description:
          'Ayam crispy renyah diulek langsung dengan racikan cabai rawit merah segar dan bawang gurih khas Bu Sari. Disajikan lengkap dengan lalapan timun dan kemangi.',
      imageUrl:
          'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      isPromo: true,
      spiceLevels: ['Level 0 (Tanpa Cabai)', 'Level 1 (Sedang - 5 Cabai)', 'Level 2 (Pedas - 10 Cabai)', 'Level 3 (Mampus - 20 Cabai)'],
      availableToppings: standardFoodToppings,
    ),
    MenuItem(
      id: 'm2',
      name: 'Nasi Goreng Spesial Bu Sari',
      category: 'Makanan Utama',
      price: 16000,
      originalPrice: null,
      rating: 4.8,
      reviewCount: 215,
      prepTimeMinutes: 12,
      description:
          'Nasi goreng harum beraroma smoky dengan suwiran ayam, sosis sapi pilihan, telur orak-arik, taburan bawang goreng, dan acar segar.',
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      spiceLevels: ['Sedang', 'Pedas Biasa', 'Super Pedas'],
      availableToppings: standardFoodToppings,
    ),
    MenuItem(
      id: 'm3',
      name: 'Paket Hemat Kenyang Mahasiswa',
      category: 'Paket Hemat',
      price: 18000,
      originalPrice: 23000,
      rating: 4.9,
      reviewCount: 450,
      prepTimeMinutes: 8,
      description:
          'Kombinasi juara paling ramah kantong: Nasi putih porsi kenyang, Ayam Goreng Lengkuas Bu Sari, Tahu Goreng, Sambal Bajak, dan Es Teh Manis Jumbo.',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      isPromo: true,
      spiceLevels: ['Pedas Sedang', 'Ekstra Pedas'],
      availableToppings: standardFoodToppings,
    ),
    MenuItem(
      id: 'm4',
      name: 'Soto Ayam Lamongan Komplit',
      category: 'Makanan Utama',
      price: 14000,
      originalPrice: null,
      rating: 4.7,
      reviewCount: 160,
      prepTimeMinutes: 10,
      description:
          'Kuah kuning kaldu ayam kampung yang gurih hangat, dipadukan suwiran ayam melimpah, soun, irisan kol, telur rebus, taburan koya gurih, dan perasan jeruk nipis.',
      imageUrl:
          'https://images.unsplash.com/photo-1572656631137-7935297eff55?auto=format&fit=crop&w=600&q=80',
      isPopular: false,
      spiceLevels: ['Original (Kuah Bening)', 'Tambah Sambal Rawit'],
      availableToppings: standardFoodToppings,
    ),
    MenuItem(
      id: 'm5',
      name: 'Mie Ayam Pangsit Bakso',
      category: 'Makanan Utama',
      price: 15000,
      originalPrice: 17000,
      rating: 4.8,
      reviewCount: 198,
      prepTimeMinutes: 10,
      description:
          'Mie kenyal racikan bumbu manis gurih dengan topping tumis ayam jamur lezat, 2 bakso sapi kenyal, pangsit goreng renyah, dan sawi hijau segar.',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      isPromo: true,
      spiceLevels: ['Biasa', 'Pedas Gurih'],
      availableToppings: standardFoodToppings,
    ),
    MenuItem(
      id: 'm6',
      name: 'Es Teh Manis Jumbo Bu Sari',
      category: 'Minuman Segar',
      price: 4000,
      originalPrice: 5000,
      rating: 4.9,
      reviewCount: 540,
      prepTimeMinutes: 3,
      description:
          'Racikan daun teh melati wangi khas Solo dengan gula pasir murni dan es batu melimpah dalam porsi cup jumbo 22 oz. Melegakan dahaga seketika!',
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      isPromo: true,
      spiceLevels: ['Manis Normal', 'Less Sugar (Sedikit Gula)', 'Tawar'],
      availableToppings: standardDrinkToppings,
    ),
    MenuItem(
      id: 'm7',
      name: 'Es Jeruk Peras Segar Asli',
      category: 'Minuman Segar',
      price: 6000,
      originalPrice: null,
      rating: 4.7,
      reviewCount: 180,
      prepTimeMinutes: 4,
      description:
          'Dibuat dari 3 buah jeruk pontianak segar yang diperas langsung saat dipesan, kaya vitamin C dan kesegaran alami.',
      imageUrl:
          'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=600&q=80',
      isPopular: false,
      spiceLevels: ['Manis Normal', 'Sedikit Gula'],
      availableToppings: standardDrinkToppings,
    ),
    MenuItem(
      id: 'm8',
      name: 'Kopi Susu Gula Aren Bu Sari',
      category: 'Minuman Segar',
      price: 10000,
      originalPrice: 12000,
      rating: 4.8,
      reviewCount: 145,
      prepTimeMinutes: 5,
      description:
          'Espresso robusta mantap dipadukan susu creamy dan sirup gula aren asli organik. Teman setia nugas dan praktikum di lab!',
      imageUrl:
          'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      isPromo: true,
      spiceLevels: ['Normal Sweet', 'Less Sweet'],
      availableToppings: standardDrinkToppings,
    ),
    MenuItem(
      id: 'm9',
      name: 'Tempe Mendoan Anget & Sambal Kecap (Isi 4)',
      category: 'Snack & Cemilan',
      price: 8000,
      originalPrice: null,
      rating: 4.9,
      reviewCount: 230,
      prepTimeMinutes: 7,
      description:
          'Tempe kedelai berbalut adonan tepung berbumbu daun bawang yang digoreng setengah matang (mendoan hangat), disajikan dengan cocolan sambal kecap rawit pedas.',
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
      isPopular: true,
      spiceLevels: ['Sambal Kecap Pedas', 'Cabai Rawit Ijo Utuh'],
      availableToppings: [],
    ),
    MenuItem(
      id: 'm10',
      name: 'Pisang Bakar Cokelat Keju Susu',
      category: 'Snack & Cemilan',
      price: 10000,
      originalPrice: null,
      rating: 4.6,
      reviewCount: 95,
      prepTimeMinutes: 8,
      description:
          'Pisang raja bakar beraroma mentega gurih, ditaburi limpahan keju cheddar parut, meses cokelat Belanda, dan kucuran susu kental manis.',
      imageUrl:
          'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=600&q=80',
      isPopular: false,
      spiceLevels: [],
      availableToppings: standardDrinkToppings,
    ),
  ];

  static List<CartItem> sampleCart = [
    CartItem(
      menu: menuList[0],
      quantity: 1,
      selectedSpiceLevel: 'Level 2 (Pedas - 10 Cabai)',
      selectedToppings: [standardFoodToppings[0]],
      specialNotes: 'Ayamnya tolong digeprek sampai hancur ya Bu',
    ),
    CartItem(
      menu: menuList[5],
      quantity: 1,
      selectedSpiceLevel: 'Manis Normal',
      selectedToppings: [],
      specialNotes: 'Es batunya jangan terlalu banyak',
    ),
  ];

  static final List<OrderHistory> orderHistories = [
    OrderHistory(
      orderId: 'BS-8821',
      orderDate: DateTime(2026, 10, 15, 12, 45),
      itemNames: ['1x Paket Hemat Kenyang Mahasiswa', '1x Tempe Mendoan'],
      totalAmount: 27000,
      subtotal: 26000,
      serviceFee: 1000,
      discountAmount: 0,
      status: 'Selesai',
      tableNumber: 'Meja 04',
      paymentMethod: 'QRIS Instant',
      isTakeaway: false,
      detailedItems: [
        {
          'name': 'Paket Hemat Kenyang Mahasiswa',
          'quantity': 1,
          'price': 18000,
          'spice': 'Pedas Sedang',
          'toppings': 'Telur Mata Sapi / Dadar',
          'notes': 'Nasi dibanyakin ya Bu',
        },
        {
          'name': 'Tempe Mendoan Anget (Isi 4)',
          'quantity': 1,
          'price': 8000,
          'spice': 'Sambal Kecap Pedas',
          'toppings': '',
          'notes': 'Goreng agak garing',
        },
      ],
    ),
    OrderHistory(
      orderId: 'BS-8790',
      orderDate: DateTime(2026, 10, 14, 13, 10),
      itemNames: ['1x Ayam Geprek Sambal Korek', '1x Es Jeruk Peras'],
      totalAmount: 22000,
      subtotal: 21000,
      serviceFee: 1000,
      discountAmount: 0,
      status: 'Selesai',
      tableNumber: 'Takeaway (Bungkus)',
      paymentMethod: 'Saldo Mahasiswa',
      isTakeaway: true,
      detailedItems: [
        {
          'name': 'Ayam Geprek Sambal Korek Bu Sari',
          'quantity': 1,
          'price': 15000,
          'spice': 'Level 2 (Pedas - 10 Cabai)',
          'toppings': '',
          'notes': 'Sambal dipisah',
        },
        {
          'name': 'Es Jeruk Peras Segar Asli',
          'quantity': 1,
          'price': 6000,
          'spice': 'Manis Normal',
          'toppings': '',
          'notes': 'Gula sedikit',
        },
      ],
    ),
  ];

  static const List<Map<String, dynamic>> promoBanners = [
    {
      'title': 'Diskon 20% Jam Makan Siang!',
      'subtitle': 'Khusus mahasiswa & staf labkom pkl 11.00 - 13.30',
      'code': 'HEMATKANTIN',
      'color': 0xFFD84315, // Deep Orange Dark
    },
    {
      'title': 'Paket Kenyang Cuma Rp 18.000',
      'subtitle': 'Sudah termasuk Nasi + Ayam Goreng + Es Teh Jumbo',
      'code': 'MAHASISWAJUARA',
      'color': 0xFFBF360C, // Deep Orange Accent
    },
    {
      'title': 'Gratis Es Teh Manis',
      'subtitle': 'Setiap pembelian 2 porsi Ayam Geprek Level apa saja',
      'code': 'GEPREKMANIA',
      'color': 0xFFE65100, // Orange
    },
  ];
}
