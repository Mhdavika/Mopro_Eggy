import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/formatters.dart';

class OrderSuccessPage extends StatelessWidget {
  final List<CartItem> items;
  final String tableNumber;
  final String paymentMethod;
  final bool isTakeaway;
  final int totalAmount;
  final String orderId;

  const OrderSuccessPage({
    super.key,
    required this.items,
    required this.tableNumber,
    required this.paymentMethod,
    required this.isTakeaway,
    required this.totalAmount,
    this.orderId = 'BS-042',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Struk Pesanan Digital'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
            // 1. Icon Sukses
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 72,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Judul & Pesan
            const Text(
              'Pesanan Berhasil Dibuat!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Silakan tunjukkan nomor antrean ini ke kasir Bu Sari',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 3. Card Nomor Antrean
            Card(
              elevation: 2,
              color: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'NOMOR ANTREAN KAMU',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '#$orderId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Estimasi Penyajian: ± 10-15 Menit',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Stepper Status Pesanan
            Card(
              elevation: 0.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Pesanan Saat Ini',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatusStep('Diterima', Icons.receipt_long, true, true),
                        _buildStatusConnector(true),
                        _buildStatusStep('Dimasak', Icons.soup_kitchen, true, false),
                        _buildStatusConnector(false),
                        _buildStatusStep('Siap Ambil', Icons.dinner_dining, false, false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. Struk Rincian Pesanan
            Card(
              elevation: 0.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rincian Transaksi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Icon(Icons.qr_code, size: 28, color: Colors.grey),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildReceiptRow('Lokasi Santap', isTakeaway ? 'Bungkus (Takeaway)' : tableNumber),
                    _buildReceiptRow('Metode Pembayaran', paymentMethod),
                    _buildReceiptRow('Waktu Pesan', 'Hari ini, ${TimeOfDay.now().format(context)}'),
                    const Divider(height: 24),
                    const Text(
                      'Menu Dipesan:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((cartItem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${cartItem.quantity}x ${cartItem.menu.name}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if (cartItem.selectedSpiceLevel.isNotEmpty)
                                    Text(
                                      '• ${cartItem.selectedSpiceLevel}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  if (cartItem.selectedToppings.isNotEmpty)
                                    Text(
                                      '• Topping: ${cartItem.selectedToppings.map((t) => t.name).join(", ")}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              formatRupiah(cartItem.itemPrice),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          formatRupiah(totalAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 6. Tombol Aksi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Daftar Menu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Struk berhasil disimpan ke perangkat!')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Unduh Struk PDF / Gambar'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildStatusStep(String label, IconData icon, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isActive ? Colors.deepOrange : Colors.grey.shade300,
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.black87 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? Colors.deepOrange : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 22),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
