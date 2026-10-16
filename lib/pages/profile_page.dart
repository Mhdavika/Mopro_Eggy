import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/local_db_service.dart';
import '../utils/formatters.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool pushNotifications = true;
  bool saveReceiptAutomatically = true;
  int walletBalance = 45000;
  int orderCount = 0;
  bool isLoading = true;

  UserProfile userProfile = UserProfile(
    name: 'Mahasiswa Labkom',
    nim: '2200018123',
    major: 'Teknik Informatika',
    phone: '0812-3456-7890',
    email: 'mahasiswa@labkom.ac.id',
  );

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);
    final balance = await LocalDbService.instance.getWalletBalance();
    final orders = await LocalDbService.instance.getOrders();
    final profile = await LocalDbService.instance.getUserProfile();
    if (mounted) {
      setState(() {
        walletBalance = balance;
        orderCount = orders.length;
        userProfile = profile;
        isLoading = false;
      });
    }
  }

  // DIALOG EDIT PROFIL
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userProfile.name);
    final nimController = TextEditingController(text: userProfile.nim);
    final majorController = TextEditingController(text: userProfile.major);
    final phoneController = TextEditingController(text: userProfile.phone);
    final emailController = TextEditingController(text: userProfile.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Edit Data Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM Mahasiswa',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'NIM tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: majorController,
                    decoration: const InputDecoration(
                      labelText: 'Program Studi / Jurusan',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor WhatsApp / HP',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Kampus',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState?.validate() == true) {
                final updated = UserProfile(
                  name: nameController.text.trim(),
                  nim: nimController.text.trim(),
                  major: majorController.text.trim(),
                  phone: phoneController.text.trim(),
                  email: emailController.text.trim(),
                );
                await LocalDbService.instance.saveUserProfile(updated);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                await _loadProfileData();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Profil berhasil diperbarui dan tersimpan di database lokal!'),
                  ),
                );
              }
            },
            child: const Text('Simpan Profil'),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog() {
    final nominals = [10000, 20000, 50000, 100000];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Isi Saldo Labkom Pay'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih nominal isi ulang yang akan disimpan ke database lokal laptop:'),
            const SizedBox(height: 12),
            ...nominals.map((nom) {
              return ListTile(
                dense: true,
                title: Text(formatRupiah(nom), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.add_circle_outline, color: Colors.deepOrange),
                onTap: () async {
                  Navigator.pop(ctx);
                  final newBalance = walletBalance + nom;
                  await LocalDbService.instance.updateWalletBalance(newBalance);
                  await _loadProfileData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Berhasil top up ${formatRupiah(nom)}! Saldo baru: ${formatRupiah(newBalance)}'),
                    ),
                  );
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
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
            child: const Text('Profil & Informasi Kantin', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Profil Pengguna Card dengan Tombol Edit
                Card(
                  elevation: 0.8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.deepOrange.shade100,
                              child: const Icon(Icons.person, size: 42, color: Colors.deepOrange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          userProfile.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(color: primaryColor),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: _showEditProfileDialog,
                                        icon: const Icon(Icons.edit, size: 14),
                                        label: const Text('Edit Profil', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'NIM: ${userProfile.nim} • ${userProfile.major}',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '⭐ Pelanggan Setia Bu Sari',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$orderCount Transaksi',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_android, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(userProfile.phone, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(userProfile.email, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Saldo Kantin Pay Card (Database Lokal)
                Card(
                  elevation: 0.8,
                  color: Colors.deepOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.storage, size: 14, color: Colors.white70),
                                SizedBox(width: 4),
                                Text(
                                  'Saldo Labkom Pay (Database Lokal)',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRupiah(walletBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _showTopUpDialog,
                          icon: const Icon(Icons.add_circle, size: 18),
                          label: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Info Kantin Bu Sari
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
                          children: [
                            Icon(Icons.storefront, color: Colors.deepOrange),
                            SizedBox(width: 8),
                            Text(
                              'Informasi Gerai Kantin Bu Sari',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildInfoItem(
                          Icons.schedule,
                          'Jam Operasional',
                          'Senin - Sabtu: 07.30 - 16.30 WIB (Hari Libur Tutup)',
                        ),
                        _buildInfoItem(
                          Icons.location_on_outlined,
                          'Lokasi Gerai Kampus',
                          'Lantai 1 Gedung Maroon Labkom (Samping Tangga Utama)',
                        ),
                        _buildInfoItem(
                          Icons.phone_outlined,
                          'WhatsApp Kasir Bu Sari',
                          '+62 812-3456-7890 (Bu Sari)',
                        ),
                        _buildInfoItem(
                          Icons.verified_outlined,
                          'Jaminan Kualitas Makanan',
                          '100% Halal, Bahan Segar Setiap Hari, Tanpa Pengawet',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Pengaturan & Preferensi
                Card(
                  elevation: 0.8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeTrackColor: primaryColor,
                        secondary: const Icon(Icons.notifications_active_outlined),
                        title: const Text('Notifikasi Status Pesanan', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Dapatkan pemberitahuan saat masakan Bu Sari sudah siap', style: TextStyle(fontSize: 12)),
                        value: pushNotifications,
                        onChanged: (val) => setState(() => pushNotifications = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        activeTrackColor: primaryColor,
                        secondary: const Icon(Icons.receipt_long_outlined),
                        title: const Text('Simpan Struk Otomatis', style: TextStyle(fontSize: 14)),
                        value: saveReceiptAutomatically,
                        onChanged: (val) => setState(() => saveReceiptAutomatically = val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.refresh, color: Colors.blue),
                        title: const Text('Reset Data Database Lokal', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Kembalikan data profil, pesanan, dan saldo ke default', style: TextStyle(fontSize: 12)),
                        onTap: () async {
                          await LocalDbService.instance.resetDatabase();
                          await _loadProfileData();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Database lokal berhasil di-reset!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Aplikasi Kantin Bu Sari v1.0.0 (Web & Mobile Responsive)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  'Tugas Praktikum Maroon Labkom',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
