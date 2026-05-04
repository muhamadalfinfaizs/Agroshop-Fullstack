import '../models/category.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/cart_item.dart';

/// Dummy data untuk pengembangan UI
/// Nanti bisa diganti dengan data dari API NestJS
class DummyData {
  DummyData._();

  // ==================== Categories ====================
  static const List<Category> categories = [
    Category(
      id: 1,
      name: 'Pupuk',
      icon: 'eco',
      imageUrl: 'https://picsum.photos/seed/fertilizer/200/200',
      productCount: 45,
    ),
    Category(
      id: 2,
      name: 'Bibit & Benih',
      icon: 'grass',
      imageUrl: 'https://picsum.photos/seed/seeds/200/200',
      productCount: 32,
    ),
    Category(
      id: 3,
      name: 'Alat Pertanian',
      icon: 'agriculture',
      imageUrl: 'https://picsum.photos/seed/tools/200/200',
      productCount: 28,
    ),
    Category(
      id: 4,
      name: 'Pestisida',
      icon: 'bug_report',
      imageUrl: 'https://picsum.photos/seed/pesticide/200/200',
      productCount: 18,
    ),
    Category(
      id: 5,
      name: 'Pupuk Organik',
      icon: 'compost',
      imageUrl: 'https://picsum.photos/seed/organic/200/200',
      productCount: 15,
    ),
    Category(
      id: 6,
      name: 'Media Tanam',
      icon: 'local_florist',
      imageUrl: 'https://picsum.photos/seed/soil/200/200',
      productCount: 22,
    ),
  ];

  // ==================== Products ====================
  static const List<Product> products = [
    // Pupuk
    Product(
      id: 1,
      name: 'Pupuk NPK Phonska Plus',
      description: 'Pupuk NPK Phonska Plus adalah pupuk majemuk lengkap dengan unsur hara makro dan mikro. Cocok untuk semua jenis tanaman pangan, hortikultura, dan plantations.\n\n✅ Unsur hara lengkap: N, P, K, S, Mg, B, Zn\n✅ Meningkatkan hasil panen\n✅ Harga terjangkau\n✅ Tersedia dalam berbagai ukuran',
      price: 135000,
      discountPrice: 120000,
      imageUrl: 'https://picsum.photos/seed/npk1/400/400',
      images: [
        'https://picsum.photos/seed/npk1/400/400',
        'https://picsum.photos/seed/npk2/400/400',
        'https://picsum.photos/seed/npk3/400/400',
      ],
      categoryId: 1,
      categoryName: 'Pupuk',
      stock: 150,
      rating: 4.8,
      reviewCount: 256,
      isFeatured: true,
      isAvailable: true,
      unit: 'zak',
    ),
    Product(
      id: 2,
      name: 'Pupuk Urea Granul',
      description: 'Pupuk urea adalah sumber nitrogen utama untuk tanaman. Dengan teknologi granul, mudah disimpan dan aplikasi.',
      price: 115000,
      imageUrl: 'https://picsum.photos/seed/urea1/400/400',
      images: [
        'https://picsum.photos/seed/urea1/400/400',
      ],
      categoryId: 1,
      categoryName: 'Pupuk',
      stock: 200,
      rating: 4.6,
      reviewCount: 189,
      isFeatured: false,
      isAvailable: true,
      unit: 'zak',
    ),
    Product(
      id: 3,
      name: 'Pupuk KCL Muriate of Potash',
      description: 'Pupuk kalium klorida untuk meningkatkan kualitas buah dan ketahanan tanaman terhadap penyakit.',
      price: 145000,
      imageUrl: 'https://picsum.photos/seed/kcl1/400/400',
      images: [
        'https://picsum.photos/seed/kcl1/400/400',
      ],
      categoryId: 1,
      categoryName: 'Pupuk',
      stock: 80,
      rating: 4.7,
      reviewCount: 124,
      isFeatured: true,
      isAvailable: true,
      unit: 'zak',
    ),

    // Bibit & Benih
    Product(
      id: 4,
      name: 'Bibit Padi IR 64 Premium',
      description: 'Bibit padi unggul IR 64 dengan kualitas germination tinggi. Cocok untuk sawah irigasi dan tadah hujan.',
      price: 65000,
      discountPrice: 55000,
      imageUrl: 'https://picsum.photos/seed/padi1/400/400',
      images: [
        'https://picsum.photos/seed/padi1/400/400',
        'https://picsum.photos/seed/padi2/400/400',
      ],
      categoryId: 2,
      categoryName: 'Bibit & Benih',
      stock: 500,
      rating: 4.9,
      reviewCount: 342,
      isFeatured: true,
      isAvailable: true,
      unit: 'kg',
    ),
    Product(
      id: 5,
      name: 'Benih Jagung Bisi 18',
      description: 'Benih jagung hibrida Bisi 18 dengan potensi hasil tinggi. Tahan penyakit bulai dan karat.',
      price: 175000,
      imageUrl: 'https://picsum.photos/seed/jagung1/400/400',
      images: [
        'https://picsum.photos/seed/jagung1/400/400',
      ],
      categoryId: 2,
      categoryName: 'Bibit & Benih',
      stock: 120,
      rating: 4.7,
      reviewCount: 198,
      isFeatured: false,
      isAvailable: true,
      unit: 'pak',
    ),
    Product(
      id: 6,
      name: 'Benih Cabai Rawit Long',
      description: 'Benih cabai rawit varietas Long dengan buah panjang dan produktif. Cocok untuk dataran rendah.',
      price: 45000,
      imageUrl: 'https://picsum.photos/seed/cabai1/400/400',
      images: [
        'https://picsum.photos/seed/cabai1/400/400',
      ],
      categoryId: 2,
      categoryName: 'Bibit & Benih',
      stock: 300,
      rating: 4.5,
      reviewCount: 156,
      isFeatured: false,
      isAvailable: true,
      unit: 'pak',
    ),

    // Alat Pertanian
    Product(
      id: 7,
      name: 'Cangkul Besi Standard',
      description: 'Cangkul berkualitas tinggi dengan mata baja tahan karat. Gagang kayu kuat dan nyaman digenggam.',
      price: 85000,
      imageUrl: 'https://picsum.photos/seed/cangkul1/400/400',
      images: [
        'https://picsum.photos/seed/cangkul1/400/400',
      ],
      categoryId: 3,
      categoryName: 'Alat Pertanian',
      stock: 75,
      rating: 4.6,
      reviewCount: 89,
      isFeatured: false,
      isAvailable: true,
      unit: 'pcs',
    ),
    Product(
      id: 8,
      name: 'Semprotan Tanaman 16L',
      description: 'Alat semprot punggung berkapasitas 16 liter dengan tekanan stabil. Include nosel berbagai ukuran.',
      price: 285000,
      discountPrice: 250000,
      imageUrl: 'https://picsum.photos/seed/semprot1/400/400',
      images: [
        'https://picsum.photos/seed/semprot1/400/400',
        'https://picsum.photos/seed/semprot2/400/400',
      ],
      categoryId: 3,
      categoryName: 'Alat Pertanian',
      stock: 45,
      rating: 4.8,
      reviewCount: 167,
      isFeatured: true,
      isAvailable: true,
      unit: 'pcs',
    ),
    Product(
      id: 9,
      name: 'Garpu Tanah Stainless',
      description: 'Garpu tanah 4 mata dari stainless steel anti karat. Ideal untuk menggemburkan tanah.',
      price: 65000,
      imageUrl: 'https://picsum.photos/seed/garpu1/400/400',
      images: [
        'https://picsum.photos/seed/garpu1/400/400',
      ],
      categoryId: 3,
      categoryName: 'Alat Pertanian',
      stock: 60,
      rating: 4.4,
      reviewCount: 67,
      isFeatured: false,
      isAvailable: true,
      unit: 'pcs',
    ),

    // Pestisida
    Product(
      id: 10,
      name: 'Insektisida Confidor 500 SC',
      description: 'Insektisida sistemik untuk mengendalikan hama pengisap pada tanaman. Aman untuk lingkungan.',
      price: 95000,
      imageUrl: 'https://picsum.photos/seed/insektisida1/400/400',
      images: [
        'https://picsum.photos/seed/insektisida1/400/400',
      ],
      categoryId: 4,
      categoryName: 'Pestisida',
      stock: 90,
      rating: 4.7,
      reviewCount: 203,
      isFeatured: true,
      isAvailable: true,
      unit: 'botol',
    ),
    Product(
      id: 11,
      name: 'Fungisida Dithane M-45',
      description: 'Fungisida kontak untuk pencegahan penyakit jamur pada tanaman. Efektif untuk berbagai crops.',
      price: 78000,
      imageUrl: 'https://picsum.photos/seed/fungisida1/400/400',
      images: [
        'https://picsum.photos/seed/fungisida1/400/400',
      ],
      categoryId: 4,
      categoryName: 'Pestisida',
      stock: 110,
      rating: 4.5,
      reviewCount: 145,
      isFeatured: false,
      isAvailable: true,
      unit: 'pak',
    ),
    Product(
      id: 12,
      name: 'Herbisida Roundup 480 SL',
      description: 'Herbisida sistemik untuk mengendalikan gulma tahunan dan tahunan. Tidak merusak tanaman utama.',
      price: 125000,
      imageUrl: 'https://picsum.photos/seed/herbisida1/400/400',
      images: [
        'https://picsum.photos/seed/herbisida1/400/400',
      ],
      categoryId: 4,
      categoryName: 'Pestisida',
      stock: 65,
      rating: 4.6,
      reviewCount: 112,
      isFeatured: false,
      isAvailable: true,
      unit: 'liter',
    ),

    // Pupuk Organik
    Product(
      id: 13,
      name: 'Pupuk Kandang Kering 20kg',
      description: 'Pupuk organik dari kotoran sapi yang sudah dikomposkan. Menambah kesuburan tanah secara alami.',
      price: 45000,
      imageUrl: 'https://picsum.photos/seed/kandang1/400/400',
      images: [
        'https://picsum.photos/seed/kandang1/400/400',
      ],
      categoryId: 5,
      categoryName: 'Pupuk Organik',
      stock: 200,
      rating: 4.4,
      reviewCount: 98,
      isFeatured: false,
      isAvailable: true,
      unit: 'zak',
    ),
    Product(
      id: 14,
      name: 'Kompos Granul Premium',
      description: 'Kompos granul siap pakai untuk semua jenis tanaman. Proses fermentasi lengkap menghasilkan nutrisi optimal.',
      price: 55000,
      discountPrice: 48000,
      imageUrl: 'https://picsum.photos/seed/kompos1/400/400',
      images: [
        'https://picsum.photos/seed/kompos1/400/400',
      ],
      categoryId: 5,
      categoryName: 'Pupuk Organik',
      stock: 180,
      rating: 4.7,
      reviewCount: 134,
      isFeatured: true,
      isAvailable: true,
      unit: 'zak',
    ),

    // Media Tanam
    Product(
      id: 15,
      name: 'Cocopeat Block 5kg',
      description: 'Media tanam cocopeat berkualitas tinggi. Kemasan kompak mudah disimpan dan transportasi.',
      price: 35000,
      imageUrl: 'https://picsum.photos/seed/cocopeat1/400/400',
      images: [
        'https://picsum.photos/seed/cocopeat1/400/400',
      ],
      categoryId: 6,
      categoryName: 'Media Tanam',
      stock: 250,
      rating: 4.6,
      reviewCount: 87,
      isFeatured: false,
      isAvailable: true,
      unit: 'block',
    ),
    Product(
      id: 16,
      name: 'Pupuk Tanah (Top Soil) 20L',
      description: 'Top soil subur untuk media tanam. Melalui proses sterilisasi untuk memastikan bebas hama.',
      price: 42000,
      imageUrl: 'https://picsum.photos/seed/topsoil1/400/400',
      images: [
        'https://picsum.photos/seed/topsoil1/400/400',
      ],
      categoryId: 6,
      categoryName: 'Media Tanam',
      stock: 150,
      rating: 4.5,
      reviewCount: 76,
      isFeatured: false,
      isAvailable: true,
      unit: 'zak',
    ),
  ];

  // ==================== Featured Products ====================
  static List<Product> get featuredProducts =>
      products.where((p) => p.isFeatured).toList();

  // ==================== Latest Products ====================
  static List<Product> get latestProducts =>
      products.reversed.toList();

  // ==================== Products by Category ====================
  static List<Product> getProductsByCategory(int categoryId) {
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  // ==================== User ====================
static final User currentUser = User(
    id: 1,
    name: 'Budi Petani',
    email: 'budi@example.com',
    role: 'FARMER', // <-- Tambahkan baris ini
    phone: '081234567890',
    imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    address: 'Jl. Pertanian No. 123, Desa Makmur, Jawa Barat',
    // joinedDate: DateTime.now().subtract(const Duration(days: 120)), <-- Hapus atau komen baris ini
  );

  // ==================== Cart Items (Dummy) ====================
  static List<CartItem> get cartItems => [
    CartItem(
      id: 1,
      product: products[0], // NPK Phonska
      quantity: 2,
      addedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CartItem(
      id: 2,
      product: products[3], // Bibit Padi
      quantity: 5,
      addedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    CartItem(
      id: 3,
      product: products[7], // Semprotan
      quantity: 1,
      addedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // ==================== Banners ====================
  static const List<Map<String, String>> banners = [
    {
      'id': '1',
      'title': 'Diskon 20% Pupuk NPK',
      'subtitle': 'Sampai 20 Juni 2026',
      'imageUrl': 'https://picsum.photos/seed/banner1/800/400',
    },
    {
      'id': '2',
      'title': 'Bibit Unggul Promo',
      'subtitle': 'Harga Spesial Hari Ini',
      'imageUrl': 'https://picsum.photos/seed/banner2/800/400',
    },
    {
      'id': '3',
      'title': 'Alat Pertanian Bundle',
      'subtitle': 'Buy 2 Get 1 Free',
      'imageUrl': 'https://picsum.photos/seed/banner3/800/400',
    },
  ];
}