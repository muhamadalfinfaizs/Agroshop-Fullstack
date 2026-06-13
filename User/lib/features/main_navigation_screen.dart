import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'product/product_list_screen.dart';
import 'profile/profile_screen.dart';
import 'chatbot/chatbot_screen.dart';
import '../core/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  // Hapus underscore (_) agar state ini menjadi publik dan bisa diakses dari file lain
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Fungsi publik untuk memindahkan tab secara paksa dari layar lain (misal dari Home)
  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pindahkan list screens ke dalam build agar bisa dibuat ulang (rebuild)
    final List<Widget> screens = [
      const HomeScreen(),
      const ProductListScreen(),

      const ProfileScreen(),
    ];

    return Scaffold(
      // KITA BUANG IndexedStack.
      // Dengan hanya memanggil screens[_currentIndex], Flutter akan membangun ulang layar 
      // setiap kali tab berganti, sehingga data API selalu fresh!
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex != 2 
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()),
              );
            },
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          )
        : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: switchTab, // Panggil fungsi switchTab
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}