import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/dummy_data.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'personal_data_screen.dart';
import 'address_screen.dart';
import 'order_history_screen.dart';

/// Profile Screen - Menampilkan data user dan menu-menu terkait
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (mounted) {
        // Sinkronkan ke DummyData
        DummyData.currentUser = User(
          id: profile.id,
          name: DummyData.currentUser.name == 'Budi Petani' ? profile.name : DummyData.currentUser.name,
          email: profile.email,
          role: profile.role,
          phone: DummyData.currentUser.phone ?? profile.phone,
          imageUrl: profile.imageUrl ?? DummyData.currentUser.imageUrl,
          address: DummyData.currentUser.address ?? profile.address,
        );
        
        setState(() {
          _user = DummyData.currentUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) {
        setState(() {
          _user = DummyData.currentUser;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final user = _user ?? DummyData.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  user.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      // Name
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingXS),
                      // Email
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      // Edit profile button
                      OutlinedButton.icon(
                        onPressed: () {
                          _showComingSoonSnackbar(context, 'Edit Profil');
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Profil'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Sections
                _buildMenuSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final user = _user ?? DummyData.currentUser;
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Akun Section
          _buildSectionTitle('Akun'),
          _buildMenuCard([
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Data Diri',
              subtitle: 'Kelola informasi pribadi',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalDataScreen()),
                );
                if (result == true) {
                  _fetchProfile();
                }
              },
            ),
            _MenuItem(
              icon: Icons.location_on_outlined,
              title: 'Alamat Pengiriman',
              subtitle: (user.address != null && user.address!.isNotEmpty) ? user.address! : 'Kelola alamat pengiriman',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressScreen()),
                );
                if (result == true) {
                  _fetchProfile();
                }
              },
            ),
          ]),

          const SizedBox(height: AppConstants.paddingL),

          // Pesanan Section
          _buildSectionTitle('Pesanan'),
          _buildMenuCard([
            _MenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Pesanan Saya',
              subtitle: 'Lihat riwayat pesanan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),
            _MenuItem(
              icon: Icons.local_shipping_outlined,
              title: 'Pengiriman',
              subtitle: 'Lacak pengiriman',
              onTap: () => _showComingSoonSnackbar(context, 'Pengiriman'),
            ),
          ]),

          const SizedBox(height: AppConstants.paddingL),

          // Lainnya Section
          _buildSectionTitle('Lainnya'),
          _buildMenuCard([
            _MenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Pengaturan notifikasi',
              onTap: () => _showComingSoonSnackbar(context, 'Notifikasi'),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              subtitle: 'Pusat bantuan & FAQ',
              onTap: () => _showComingSoonSnackbar(context, 'Bantuan'),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Kami',
              subtitle: 'Informasi aplikasi',
              onTap: () => _showAboutDialog(context),
            ),
          ]),

          const SizedBox(height: AppConstants.paddingL),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Keluar',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingXL),

          // App Version
          Center(
            child: Text(
              'AgroShop v1.0.0',
              style: TextStyle(
                color: AppColors.textHint.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Card(
      elevation: 1,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 72),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera tersedia!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Tentang AgroShop'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgroShop adalah aplikasi toko online untuk kebutuhan pertanian.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text('Versi: 1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('© 2026 AgroShop. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Hapus token JWT
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil keluar!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                // Arahkan ke halaman login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}