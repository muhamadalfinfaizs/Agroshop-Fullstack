import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_card.dart';
import '../product/product_list_screen.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  List<Category> _categories = [];
  List<Product> _featuredProducts = [];
  List<Product> _latestProducts = [];
  List<dynamic> _banners = [];

  @override
  void initState() {
    super.initState();
    _fetchHomeData(); // Panggil API saat layar pertama kali dimuat
  }

  // --- FUNGSI FETCH DATA ---
  Future<void> _fetchHomeData() async {
    try {
      // Kita gunakan Future.wait agar ketiga request berjalan paralel (bersamaan)
      // Ini membuat loading jauh lebih cepat daripada dipanggil satu-satu
      final results = await Future.wait([
        ApiService.getCategories(),
        ApiService.getProducts(),
        ApiService.getBanners(),
      ]);

      // Ekstrak hasil dari Future.wait
      final fetchedCategories = results[0] as List<Category>;
      final fetchedProducts = results[1] as List<Product>;
      final fetchedBanners = results[2];

      // Filter produk untuk ditampilkan di UI
      final featured = fetchedProducts.where((p) => p.isFeatured).toList();
      
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          _featuredProducts = featured;
          _latestProducts = fetchedProducts; // Tampilkan semua sebagai latest
          _banners = fetchedBanners;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data dari server')),
        );
      }
    }
  }

  // Fungsi untuk mengeksekusi Add to Cart
  Future<void> _addToCart(Product product) async {
    try {
      // Kita panggil API, default quantity kita set 1 untuk dari halaman Home
      await ApiService.addToCart(product.id, 1);
      
    if (mounted) {
        // Hapus SnackBar lama jika pengguna nge-spam tombol Add to Cart
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ditambahkan ke keranjang!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3), // Durasi 3 detik
            behavior: SnackBarBehavior.floating, // Melayang
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Langsung tutup snackbar
                
                // Cari Navigation Bawah, lalu paksa pindah ke Tab 2 (Keranjang)
                context.findAncestorStateOfType<MainNavigationScreenState>()?.switchTab(2);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan ke keranjang. Silakan login ulang.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 60,
                  floating: true,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryDark, AppColors.primary],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur search coming soon!')),
                        );
                      },
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                        // Nanti cart item ini juga akan kita sambungkan ke API
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '0', // Sementara diset 0 sebelum integrasi Cart API
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Banner Promo
                if (_banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildBanner(),
                  ),

                // Section Title Kategori
                if (_categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionTitle('Kategori', onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                        ),
                      );
                    }),
                  ),

                // Categories Grid
                if (_categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildCategories(),
                  ),

                // Section Title Produk Unggulan
                if (_featuredProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionTitle('Produk Unggulan', onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(isFeatured: true),
                        ),
                      );
                    }),
                  ),

                // Featured Products List
                if (_featuredProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildFeaturedProducts(),
                  ),

                // Section Title Produk Terbaru
                if (_latestProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionTitle('Produk Terbaru', onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                        ),
                      );
                    }),
                  ),

                // Latest Products Grid
                if (_latestProducts.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    sliver: _buildLatestProducts(),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppConstants.paddingXL),
                ),
              ],
            ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(AppConstants.paddingM),
      child: PageView.builder(
        controller: _bannerController,
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.eco,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner['title'] ?? 'Promo Spesial',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        banner['subtitle'] ?? 'Dapatkan sekarang juga!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Lihat Promo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingL,
        AppConstants.paddingM,
        AppConstants.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Lihat Semua'),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return SizedBox(
            width: 100,
            child: CategoryCard(
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
        itemCount: _featuredProducts.length,
        itemBuilder: (context, index) {
          final product = _featuredProducts[index];
          return SizedBox(
            width: 160,
            child: ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              onAddToCart: () => _addToCart(product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestProducts() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: AppConstants.gridSpacing,
        mainAxisSpacing: AppConstants.gridSpacing,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = _latestProducts[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            onAddToCart: () => _addToCart(product),
          );
        },
        childCount: _latestProducts.length,
      ),
    );
  }
}