import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../../services/api_service.dart';

/// Product List Screen - Menampilkan daftar produk dengan filter dan sorting
class ProductListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final bool isFeatured;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.isFeatured = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _sortBy = 'terbaru';
  RangeValues _priceRange = const RangeValues(0, 500000);
  bool _isLoading = true;
  List<Product> _allProducts = [];
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await ApiService.getProducts();
      if (mounted) {
        setState(() {
          _allProducts = fetchedProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data dari server')),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      await ApiService.addToCart(product.id, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ditambahkan ke keranjang!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
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

  List<Product> get _filteredProducts {
    List<Product> products = List.from(_allProducts);

    // Filter berdasarkan category atau featured
    if (widget.categoryId != null) {
      products = products.where((p) => p.categoryId == widget.categoryId).toList();
    } else if (widget.isFeatured) {
      products = products.where((p) => p.isFeatured).toList();
    }

    // Filter berdasarkan harga
    products = products.where((p) {
      return p.displayPrice >= _priceRange.start &&
          p.displayPrice <= _priceRange.end;
    }).toList();

    // Sorting
    switch (_sortBy) {
      case 'termahal':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'termurah':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'terlaris':
        products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'terbaru':
      default:
        products.sort((a, b) => b.id.compareTo(a.id));
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName ??
        (widget.isFeatured ? 'Produk Unggulan' : 'Semua Produk');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: ApiService.cartBadgeCount,
            builder: (context, count, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              color: AppColors.primary,
              child: Column(
                children: [
                  // Filter & Sort Bar
                  _buildFilterBar(),

                  // Product Grid
                  Expanded(
                    child: _buildGridView(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          // Sort dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
                    DropdownMenuItem(value: 'termurah', child: Text('Termurah')),
                    DropdownMenuItem(value: 'termahal', child: Text('Termahal')),
                    DropdownMenuItem(value: 'terlaris', child: Text('Terlaris')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          // Filter button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.primary),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    final products = _filteredProducts;
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: AppConstants.gridSpacing,
        mainAxisSpacing: AppConstants.gridSpacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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
          onAddToCart: () {
            _addToCart(product);
          },
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Urutkan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Price Range
                  const Text(
                    'Rentang Harga',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 500000,
                    divisions: 10,
                    labels: RangeLabels(
                      'Rp ${(_priceRange.start / 1000).round()}rb',
                      'Rp ${(_priceRange.end / 1000).round()}rb',
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                      setState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rp ${(_priceRange.start / 1000).round()}rb'),
                      Text('Rp ${(_priceRange.end / 1000).round()}rb'),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingL),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                ],
              ),
            );
          },
        );
      },
    );
  }


}