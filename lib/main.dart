import 'package:flutter/material.dart';

import 'pages/history_page.dart';
import 'pages/main_navigation_page.dart';
import 'pages/menu_detail_page.dart';
import 'pages/menu_list_page.dart';
import 'pages/order_page.dart';
import 'pages/profile_page.dart';

import 'services/local_db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDbService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kantin Bu Sari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),

      // Daftarkan semua route aplikasi Kantin Bu Sari
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationPage(),
        '/menu': (context) => const MenuListPage(),
        '/detail': (context) => const MenuDetailPage(),
        '/pesan': (context) => const OrderPage(),
        '/riwayat': (context) => const HistoryPage(),
        '/profil': (context) => const ProfilePage(),
      },
    );
  }
}
