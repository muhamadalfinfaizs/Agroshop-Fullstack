import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/dummy_data.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';

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
  bool _isGridView = true;
  String _sortBy = 'terbaru';
  RangeValues _priceRange = const RangeValues(0, 500000);

  List<Product> get _filteredProducts {
    List<Product> products;

    // Filter berdasarkan category atau featured
    if (widget.categoryId != null) {
      products = DummyData.getProductsByCategory(widget.categoryId!);
    } else if (widget.isFeatured) {
      products = DummyData.featuredProducts;
    } else {
      products = DummyData.products;
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
          // Cart button
          Stack(
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
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${DummyData.cartItems.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Sort Bar
          _buildFilterBar(),

          // Product List/Grid
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
      // Filter button
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.filter_list, color: Colors.white),
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
            _showAddedSnackbar(context, product.name);
          },
        );
      },
    );
  }

  Widget _buildListView() {
    final products = _filteredProducts;
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppConstants.paddingS),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                Icons.eco,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating} (${product.reviewCount})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(product.displayPrice)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
              onPressed: () {
                _showAddedSnackbar(context, product.name);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          ),
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

  void _showAddedSnackbar(BuildContext context, String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName ditambahkan ke keranjang!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}rb';
    }
    return price.toStringAsFixed(0);
  }
}