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
  final int subtotal;
  final int serviceFee;
  final int discountAmount;

  const OrderSuccessPage({
    super.key,
    required this.items,
    required this.tableNumber,
    required this.paymentMethod,
    required this.isTakeaway,
    required this.totalAmount,
    this.orderId = 'BS-042',
    this.subtotal = 0,
    this.serviceFee = 0,
    this.discountAmount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final computedSubtotal = subtotal > 0
        ? subtotal
        : items.fold<int>(0, (sum, item) => sum + item.itemPrice);
    final effectiveTotal = totalAmount > 0
        ? totalAmount
        : (computedSubtotal + serviceFee - discountAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: const Text('Struk & Konfirmasi Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // 1. Icon Sukses
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Judul
                const Text(
                  'Pembayaran & Pesanan Berhasil!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Data pesanan sudah tersimpan di database lokal laptop dan diteruskan ke dapur Bu Sari.',
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
                          'NOMOR ANTREAN PESANAN',
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Estimasi Selesai: ± 10-15 Menit',
                                style: TextStyle(
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
                const SizedBox(height: 16),

                // 4. Stepper Status Pesanan
                Card(
                  elevation: 0.8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Proses Dapur',
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
                const SizedBox(height: 16),

                // 5. Struk Rincian Pesanan
                Card(
                  elevation: 0.8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Struk Transaksi Digital',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Icon(Icons.qr_code, size: 28, color: Colors.grey),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildReceiptRow('Tempat Santap', isTakeaway ? 'Bungkus (Takeaway)' : tableNumber),
                        _buildReceiptRow('Metode Pembayaran', paymentMethod),
                        _buildReceiptRow('Status Pembayaran', 'Lunas / Berhasil'),
                        _buildReceiptRow('Waktu Transaksi', 'Hari ini, ${TimeOfDay.now().format(context)}'),
                        const Divider(height: 24),
                        const Text(
                          'Menu yang Dipesan:',
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
                                          '• Varian: ${cartItem.selectedSpiceLevel}',
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
                        if (computedSubtotal > 0)
                          _buildReceiptRow('Subtotal Menu', formatRupiah(computedSubtotal)),
                        if (serviceFee > 0)
                          _buildReceiptRow('Biaya Layanan Kantin', formatRupiah(serviceFee)),
                        if (discountAmount > 0)
                          _buildReceiptRow('Diskon Voucher', '- ${formatRupiah(discountAmount)}'),
                        if (computedSubtotal > 0 || serviceFee > 0 || discountAmount > 0)
                          const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              formatRupiah(effectiveTotal),
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
                const SizedBox(height: 20),

                // 6. Tombol Aksi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Kembali ke Daftar Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
