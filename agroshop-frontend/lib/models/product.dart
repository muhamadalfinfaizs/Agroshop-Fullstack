/// Model untuk produk
/// Struktur ini dirancang agar mudah di-parse dari JSON API NestJS
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final List<String> images;
  final int categoryId;
  final String categoryName;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isAvailable;
  final String unit; // kg, pcs, pack, dll

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    this.isFeatured = false,
    this.isAvailable = true,
    required this.unit,
  });

  /// Factory constructor untuk parsing dari JSON
  /// Siap untuk integrasi dengan NestJS API
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      stock: json['stock'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      unit: json['unit'] as String,
    );
  }

  /// Convert ke JSON untuk request ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'unit': unit,
    };
  }

  /// Copy with method untuk immutable updates
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    List<String>? images,
    int? categoryId,
    String? categoryName,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isAvailable,
    String? unit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      unit: unit ?? this.unit,
    );
  }

  /// Getter untuk harga yang ditampilkan (pakai harga diskon jika ada)
  double get displayPrice => discountPrice ?? price;

  /// Getter untuk cek apakah ada diskon
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Getter untuk persentase diskon
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100).round();
  }
}