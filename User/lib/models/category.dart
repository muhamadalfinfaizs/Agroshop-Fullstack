/// Model untuk kategori produk
/// Struktur ini dirancang agar mudah di-parse dari JSON API NestJS
class Category {
  final int id;
  final String name;
  final String icon;
  final String imageUrl;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.productCount,
  });

  /// Factory constructor untuk parsing dari JSON
  /// Siap untuk integrasi dengan NestJS API
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      imageUrl: json['imageUrl'] as String,
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  /// Convert ke JSON untuk request ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }

  /// Copy with method untuk immutable updates
  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? imageUrl,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      productCount: productCount ?? this.productCount,
    );
  }
}