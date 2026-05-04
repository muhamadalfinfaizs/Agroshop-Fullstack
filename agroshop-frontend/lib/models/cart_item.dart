import 'product.dart';

/// Model untuk item di keranjang belanja
class CartItem {
  final int id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  /// Factory constructor untuk parsing dari JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Ekstrak data produk yang "setengah matang" dari NestJS
    final productJson = json['product'] as Map<String, dynamic>? ?? {};

    return CartItem(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      
      // Kita rangkai model Product secara manual agar tidak crash.
      // Data yang tidak dikirim backend akan diisi nilai default.
      product: Product(
        id: json['productId'] as int? ?? 0, // productId ternyata dikirim di root item keranjang
        name: productJson['name'] as String? ?? 'Produk',
        description: '', // Kosongkan karena backend tidak mengirimkannya
        price: (productJson['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: productJson['imageUrl'] as String? ?? '',
        images: [], // List kosong
        categoryId: 0,
        categoryName: 'Etalase',
        stock: 999, // Beri stok tinggi agar tombol (+) di keranjang bisa ditekan
        rating: 0.0,
        reviewCount: 0,
        unit: 'pcs',
      ),
    );
  }

  /// Convert ke JSON untuk request ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Copy with method untuk immutable updates
  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Total harga untuk item ini
  double get totalPrice => product.displayPrice * quantity;
}