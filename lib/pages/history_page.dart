import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/local_db_service.dart';
import '../utils/formatters.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Semua';
  final List<String> filterTabs = ['Semua', 'Selesai', 'Sedang Dimasak'];
  List<OrderHistory> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    final data = await LocalDbService.instance.getOrders();
    if (mounted) {
      setState(() {
        orders = data;
        isLoading = false;
      });
    }
  }

  List<OrderHistory> get filteredOrders {
    if (selectedFilter == 'Semua') return orders;
    return orders.where((o) => o.status.toLowerCase() == selectedFilter.toLowerCase()).toList();
  }

  // DIALOG RINCIAN TRANSAKSI DETAIL
  void _showOrderDetailDialog(OrderHistory order) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long, color: Colors.deepOrange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Order #${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_formatDate(order.orderDate), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                // Status Badge & Info Meja
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status Pesanan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            order.status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: order.status.contains('Dimasak') ? Colors.deepOrange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Lokasi / Tempat', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(order.tableNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Metode Pembayaran
                Row(
                  children: [
                    const Icon(Icons.payment, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Metode Pembayaran:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const Divider(height: 20),

                // Daftar Item Lengkap
                const Text('Menu yang Dipesan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),

                if (order.detailedItems.isNotEmpty)
                  ...order.detailedItems.map((item) {
                    final qty = item['quantity'] ?? 1;
                    final name = item['name'] ?? '';
                    final price = item['price'] ?? 0;
                    final spice = item['spice'] ?? '';
                    final toppings = item['toppings'] ?? '';
                    final notes = item['notes'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${qty}x $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                if (spice.toString().isNotEmpty)
                                  Text('• Varian: $spice', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                if (toppings.toString().isNotEmpty)
                                  Text('• Topping: $toppings', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                if (notes.toString().isNotEmpty)
                                  Text('• Catatan: "$notes"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Text(formatRupiah(price is int ? price : (price as num).toInt()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    );
                  })
                else
                  ...order.itemNames.map((name) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• $name', style: const TextStyle(fontSize: 13)),
                    );
                  }),

                const Divider(height: 20),

                // Rincian Biaya
                if (order.subtotal > 0)
                  _buildCostRow('Subtotal', formatRupiah(order.subtotal)),
                _buildCostRow('Biaya Layanan Kantin', formatRupiah(order.serviceFee)),
                if (order.discountAmount > 0)
                  _buildCostRow('Diskon Voucher', '- ${formatRupiah(order.discountAmount)}', color: Colors.green),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      formatRupiah(order.totalAmount),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: primaryColor),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Struk digital berhasil dicetak/diunduh!')),
              );
            },
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Cetak Struk'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Row(
              children: [
                const Expanded(child: Text('Riwayat Transaksi (Database Lokal)', style: TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Segarkan Riwayat',
                  onPressed: _loadOrders,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              // 1. Filter Chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: filterTabs.map((tab) {
                    final isSelected = selectedFilter == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(tab),
                        selected: isSelected,
                        selectedColor: primaryColor.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() => selectedFilter = tab);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),

              // 2. Daftar Transaksi
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                    : filteredOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada riwayat pesanan',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            color: primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                final isCooked = order.status.contains('Dimasak');

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  elevation: 0.8,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _showOrderDetailDialog(order),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.receipt, size: 18, color: Colors.deepOrange),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '#${order.orderId}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isCooked ? Colors.orange.shade50 : Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: isCooked ? Colors.orange.shade300 : Colors.green.shade300),
                                                ),
                                                child: Text(
                                                  order.status,
                                                  style: TextStyle(
                                                    color: isCooked ? Colors.deepOrange : Colors.green,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${order.tableNumber} • ${_formatDate(order.orderDate)} • ${order.paymentMethod}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          const Divider(height: 20),

                                          // List Item Ringkas
                                          ...order.itemNames.map((item) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.circle, size: 6, color: Colors.deepOrange),
                                                  const SizedBox(width: 8),
                                                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                                                ],
                                              ),
                                            );
                                          }),
                                          const Divider(height: 20),

                                          // Total & Tombol Aksi
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Total Bayar', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                                  Text(
                                                    formatRupiah(order.totalAmount),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () => _showOrderDetailDialog(order),
                                                    icon: const Icon(Icons.info_outline, size: 16),
                                                    label: const Text('Detail Struk', style: TextStyle(fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
