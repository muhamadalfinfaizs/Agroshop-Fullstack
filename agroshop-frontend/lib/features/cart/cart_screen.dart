import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/cart_item.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/price_tag.dart';

/// Cart Screen - Menampilkan item di keranjang dengan quantity control (Terintegrasi API)
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getCart();
      if (mounted) {
        setState(() {
          _cartItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data keranjang')),
        );
      }
    }
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get _shipping => _subtotal > 200000 ? 0 : 15000;
  double get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: _showClearCartDialog,
              child: const Text(
                'Hapus Semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _cartItems.isEmpty 
          ? _buildEmptyCart() 
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                child: _buildCartList(),
              ),
            ),
      bottomNavigationBar: (!_isLoading && _cartItems.isNotEmpty) ? _buildCheckoutBar() : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.textHint.withValues(alpha: 0.5), // Sudah di-update agar bebas linter warning
          ),
          const SizedBox(height: AppConstants.paddingL),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          const Text(
            'Silakan pilih produk terlebih dahulu',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.paddingL),
          CustomButton(
            text: 'Mulai Belanja',
            icon: Icons.shopping_bag_outlined,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return _buildCartItemCard(item, index);
      },
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image (Untuk sementara dummy icon, nanti bisa diubah pakai Image.network)
                Container(
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
                const SizedBox(width: AppConstants.paddingM),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.product.categoryName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PriceTag(
                        price: item.product.price,
                        discountPrice: item.product.discountPrice,
                        compact: true,
                        showDiscountPercent: false,
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const Divider(height: AppConstants.paddingL),
            // Quantity & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity control
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: item.quantity > 1
                          ? () => _updateQuantity(index, item.quantity - 1)
                          : null,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: item.quantity < item.product.stock
                          ? () => _updateQuantity(index, item.quantity + 1)
                          : null,
                    ),
                  ],
                ),
                // Item total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Rp ${_formatPrice(item.totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        color: onPressed != null ? AppColors.primary : AppColors.textHint,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                Text('Rp ${_formatPrice(_subtotal)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ongkos Kirim', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  _shipping == 0 ? 'Gratis' : 'Rp ${_formatPrice(_shipping)}',
                  style: TextStyle(
                    color: _shipping == 0 ? AppColors.success : null,
                  ),
                ),
              ],
            ),
            const Divider(height: AppConstants.paddingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Rp ${_formatPrice(_total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            CustomButton(
              text: 'Checkout',
              icon: Icons.shopping_cart_checkout,
              isFullWidth: true,
              onPressed: _showCheckoutDialog,
            ),
          ],
        ),
      ),
    );
  }

  // --- API INTEGRATION LOGIC --- //

  Future<void> _updateQuantity(int index, int newQuantity) async {
    final item = _cartItems[index];
    final oldQuantity = item.quantity;

    // Optimistic Update: Ubah UI dulu biar terasa cepat
    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQuantity);
    });

    try {
      // Tembak API di background
      await ApiService.updateCartItemQuantity(item.id, newQuantity);
    } catch (e) {
      // Jika API gagal, kembalikan quantity di UI ke semula
      if (mounted) {
        setState(() {
          _cartItems[index] = item.copyWith(quantity: oldQuantity);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah jumlah. Periksa koneksi.'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _removeItem(int index) async {
    final item = _cartItems[index];

    // Optimistic Update
    setState(() {
      _cartItems.removeAt(index);
    });

    try {
      await ApiService.removeCartItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item dihapus dari keranjang'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      // Jika gagal dihapus di backend, kembalikan data ke UI
      if (mounted) {
        setState(() {
          _cartItems.insert(index, item);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus item.'), backgroundColor: AppColors.error),
        );
      }
    }
  }

void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Item?'),
        content: const Text('Apakah Anda yakin ingin mengosongkan keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog dulu
              setState(() => _isLoading = true);
              
              try {
                await ApiService.clearCart();
                
                if (!mounted) return; // Gaya penulisan baru yang disukai linter Flutter
                setState(() {
                  _cartItems.clear();
                  _isLoading = false;
                });
              } catch (e) {
                if (!mounted) return; // Gaya penulisan baru yang disukai linter Flutter
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal mengosongkan keranjang.'), 
                    backgroundColor: AppColors.error
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    // Checkout sementara belum disambung ke API (hanya pop up UI)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 60,
            ),
            const SizedBox(height: AppConstants.paddingM),
            const Text(
              'Checkout Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'Total pembayaran: Rp ${_formatPrice(_total)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.paddingS),
            const Text(
              'Pesanan Anda akan diproses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
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