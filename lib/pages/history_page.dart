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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Row(
              children: [
                const Expanded(child: Text('Riwayat Pesanan (Database Lokal)')),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header: Order ID & Status Badge
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

                                        // Lokasi / Meja & Tanggal
                                        Text(
                                          '${order.tableNumber} • ${_formatDate(order.orderDate)}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const Divider(height: 20),

                                        // List Items
                                        ...order.itemNames.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.circle, size: 6, color: Colors.deepOrange),
                                                const SizedBox(width: 8),
                                                Text(item, style: const TextStyle(fontSize: 13)),
                                              ],
                                            ),
                                          );
                                        }),
                                        const Divider(height: 20),

                                        // Total & Tombol Pesan Lagi
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Total Transaksi', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                                Text(
                                                  formatRupiah(order.totalAmount),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: primaryColor,
                                                side: BorderSide(color: primaryColor),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(context, '/pesan');
                                              },
                                              icon: const Icon(Icons.refresh, size: 16),
                                              label: const Text('Pesan Lagi', style: TextStyle(fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ],
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
