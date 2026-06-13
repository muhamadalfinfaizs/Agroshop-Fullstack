import 'dart:async';
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

  // --- SEARCH VARIABLES ---
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<Product> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchVisible = false;

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

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await ApiService.getProducts(search: query);
      if (mounted && _searchQuery == query) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchHomeData,
              color: AppColors.primary,
              child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 60,
                  floating: true,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  centerTitle: false,
                  title: const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isSearchVisible = !_isSearchVisible;
                          if (!_isSearchVisible) {
                            _searchController.clear();
                            _onSearchChanged(''); // Reset search
                          }
                        });
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: ApiService.cartBadgeCount,
                      builder: (context, count, child) {
                        return Stack(
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
                            if (count > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    count.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                // Search Bar (Hanya tampil jika _isSearchVisible true)
                if (_isSearchVisible)
                  SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          borderSide: const BorderSide(color: AppColors.primaryLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          borderSide: const BorderSide(color: AppColors.primaryLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                ),

                // Banner Promo (Selalu tampil di bawah appbar/search)
                if (_banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildBanner(),
                  ),

                if (_searchQuery.isNotEmpty) ...[
                  // --- TAMPILAN PENCARIAN ---
                  if (_isSearching)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  else if (_searchResults.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('Tidak ada produk bernama "$_searchQuery"'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: AppConstants.gridSpacing,
                          mainAxisSpacing: AppConstants.gridSpacing,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = _searchResults[index];
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
                          childCount: _searchResults.length,
                        ),
                      ),
                    ),
                ] else ...[
                  // --- TAMPILAN BERANDA NORMAL ---
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

                // Empty State jika benar-benar kosong
                if (_categories.isEmpty && _latestProducts.isEmpty && !_isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 80,
                            color: AppColors.textHint.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada kategori/produk yang ditambahkan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppConstants.paddingXL),
                ),
              ],
            ),
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
              color: AppColors.primary,
              image: banner['imageUrl'] != null && banner['imageUrl'].toString().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(banner['imageUrl']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (banner['imageUrl'] == null || banner['imageUrl'].toString().isEmpty)
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