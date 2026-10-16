import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/menu_item.dart';
import '../services/local_db_service.dart';
import '../utils/formatters.dart';
import 'order_success_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late List<CartItem> cartItems;
  bool isInitialized = false;

  String selectedTable = 'Meja 03 (Dekat Jendela)';
  final List<String> tableOptions = [
    'Meja 01 (Depan Kasir)',
    'Meja 02 (Area Tengah)',
    'Meja 03 (Dekat Jendela)',
    'Meja 04 (Area Belakang)',
    'Meja 05 (Outdoor)',
    'Meja 06 (Lesehan)',
  ];

  String paymentMethod = 'QRIS Instant';
  final List<Map<String, dynamic>> paymentOptions = [
    {'id': 'QRIS Instant', 'title': 'QRIS (Semua E-Wallet & M-Banking)', 'icon': Icons.qr_code_scanner},
    {'id': 'Tunai di Kasir', 'title': 'Bayar Tunai Langsung ke Bu Sari', 'icon': Icons.payments_outlined},
    {'id': 'Saldo Mahasiswa', 'title': 'Kartu Mahasiswa / Labkom Pay', 'icon': Icons.credit_card},
  ];

  bool isTakeaway = false;
  bool needCutlery = true;
  String discountCode = '';
  int discountAmount = 0;
  final TextEditingController _voucherController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is CartItem) {
        cartItems = [args];
      } else if (args is List<CartItem>) {
        cartItems = List.from(args);
      } else {
        cartItems = List.from(DummyData.sampleCart);
      }
      isInitialized = true;
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  int get subtotal => cartItems.fold(0, (sum, item) => sum + item.itemPrice);
  int get serviceFee => 1000;
  int get finalTotal {
    int total = subtotal + serviceFee - discountAmount;
    return total < 0 ? 0 : total;
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    if (code == 'HEMATKANTIN') {
      setState(() {
        discountAmount = (subtotal * 0.20).round();
        discountCode = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Voucher HEMATKANTIN aktif! Diskon 20% (${formatRupiah(discountAmount)})'),
        ),
      );
    } else if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode voucher terlebih dahulu.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Kode voucher tidak valid atau sudah kedaluwarsa.'),
        ),
      );
    }
  }

  Future<void> _confirmOrder() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang belanja kosong!')),
      );
      return;
    }

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.deepOrange),
                SizedBox(height: 16),
                Text('Menyimpan ke database lokal & mengirim ke Bu Sari...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Generate Order ID & simpan ke database lokal
    final generatedOrderId = 'BS-${(DateTime.now().millisecondsSinceEpoch % 9000) + 1000}';
    final newOrder = OrderHistory(
      orderId: generatedOrderId,
      orderDate: DateTime.now(),
      itemNames: cartItems.map((e) => '${e.quantity}x ${e.menu.name}').toList(),
      totalAmount: finalTotal,
      status: 'Sedang Dimasak',
      tableNumber: isTakeaway ? 'Bungkus (Takeaway)' : selectedTable,
    );

    // Simpan ke SharedPreferences lokal
    await LocalDbService.instance.saveOrder(newOrder);

    // Jika bayar pakai Saldo Mahasiswa, potong saldo
    if (paymentMethod == 'Saldo Mahasiswa') {
      final currentBal = await LocalDbService.instance.getWalletBalance();
      if (currentBal >= finalTotal) {
        await LocalDbService.instance.updateWalletBalance(currentBal - finalTotal);
      }
    }

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pop(context); // Tutup dialog

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessPage(
          items: cartItems,
          tableNumber: selectedTable,
          paymentMethod: paymentMethod,
          isTakeaway: isTakeaway,
          totalAmount: finalTotal,
          orderId: generatedOrderId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWeb = screenWidth >= 850;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: const Text('Konfirmasi & Keranjang Pesanan'),
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Keranjang kamu masih kosong', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Pilih Menu Sekarang'),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isDesktopOrWeb
                    // LAYOUT RESPONSIF DESKTOP / WEB (2 KOLOM)
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kolom Kiri: Pengaturan Meja & Pembayaran
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTableAndOptionCard(primaryColor),
                                  const SizedBox(height: 16),
                                  _buildPaymentMethodCard(primaryColor),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Kolom Kanan: Daftar Item & Rincian Pembayaran
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCartItemsList(primaryColor),
                                  const SizedBox(height: 16),
                                  _buildVoucherCard(primaryColor),
                                  const SizedBox(height: 16),
                                  _buildSummaryAndCheckout(primaryColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    // LAYOUT RESPONSIF MOBILE (1 KOLOM)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTableAndOptionCard(primaryColor),
                            const SizedBox(height: 16),
                            _buildCartItemsList(primaryColor),
                            const SizedBox(height: 16),
                            _buildVoucherCard(primaryColor),
                            const SizedBox(height: 16),
                            _buildPaymentMethodCard(primaryColor),
                            const SizedBox(height: 16),
                            _buildSummaryAndCheckout(primaryColor),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ),
    );
  }

  Widget _buildTableAndOptionCard(Color primaryColor) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.place, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text('Informasi Meja & Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(height: 20),
            if (!isTakeaway) ...[
              const Text('Pilih Nomor Meja Kamu:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedTable,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: tableOptions.map((table) {
                  return DropdownMenuItem(value: table, child: Text(table, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedTable = val);
                },
              ),
              const SizedBox(height: 12),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: primaryColor,
              title: const Text('Bungkus / Take Away', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Pesanan dikemas rapi untuk dibawa pulang', style: TextStyle(fontSize: 12)),
              value: isTakeaway,
              onChanged: (val) => setState(() => isTakeaway = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: primaryColor,
              title: const Text('Sertakan Sendok & Sedotan', style: TextStyle(fontSize: 14)),
              value: needCutlery,
              onChanged: (val) => setState(() => needCutlery = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsList(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pesanan Kamu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...cartItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0.5,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.menu.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 64,
                        height: 64,
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
                        Text(item.menu.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        if (item.selectedSpiceLevel.isNotEmpty)
                          Text('Varian: ${item.selectedSpiceLevel}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        if (item.selectedToppings.isNotEmpty)
                          Text('Topping: ${item.selectedToppings.map((t) => t.name).join(", ")}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        if (item.specialNotes.isNotEmpty)
                          Text('Catatan: "${item.specialNotes}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text(formatRupiah(item.itemPrice), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => setState(() => cartItems.removeAt(index)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: item.quantity > 1 ? () => setState(() => item.quantity--) : null,
                              child: const Icon(Icons.remove, size: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            InkWell(
                              onTap: () => setState(() => item.quantity++),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVoucherCard(Color primaryColor) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _voucherController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Kode Promo (Cth: HEMATKANTIN)',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: _applyVoucher,
              child: const Text('Terapkan', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilihan Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          elevation: 0.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: paymentOptions.map((opt) {
              final isSelected = paymentMethod == opt['id'];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: isSelected ? primaryColor.withValues(alpha: 0.05) : null,
                leading: Icon(opt['icon'] as IconData, color: isSelected ? primaryColor : Colors.grey),
                title: Text(
                  opt['id'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                    color: isSelected ? primaryColor : Colors.black87,
                  ),
                ),
                subtitle: Text(opt['title'] as String, style: const TextStyle(fontSize: 12)),
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? primaryColor : Colors.grey,
                ),
                onTap: () => setState(() => paymentMethod = opt['id'] as String),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryAndCheckout(Color primaryColor) {
    return Column(
      children: [
        Card(
          elevation: 0.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Biaya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Divider(height: 20),
                _buildCostRow('Subtotal Menu', formatRupiah(subtotal)),
                _buildCostRow('Biaya Layanan Kantin', formatRupiah(serviceFee)),
                if (discountAmount > 0)
                  _buildCostRow('Diskon Voucher ($discountCode)', '- ${formatRupiah(discountAmount)}', textColor: Colors.green),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      formatRupiah(finalTotal),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: _confirmOrder,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Konfirmasi & Bayar (${formatRupiah(finalTotal)})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, String amount, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
