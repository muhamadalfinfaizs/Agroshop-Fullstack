import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const PRODUCT_SELECT = {
  id: true,
  name: true,
  price: true,
  discountPrice: true,
  stock: true,
  unit: true,
  isAvailable: true,
  imageUrl: true,
  category: { select: { name: true } },
} as const;

const CATEGORY_RULES = [
  { label: 'Benih', aliases: ['benih', 'bibit', 'biji'] },
  { label: 'Pupuk', aliases: ['pupuk', 'npk', 'urea', 'kompos', 'kandang'] },
  {
    label: 'Alat Tani',
    aliases: [
      'alat',
      'alat tani',
      'cangkul',
      'sprayer',
      'sabit',
      'selang',
      'gunting',
      'penyiram',
      'gendong',
    ],
  },
  {
    label: 'Pestisida',
    aliases: [
      'pestisida',
      'obat',
      'obat hama',
      'insektisida',
      'fungisida',
      'herbisida',
      'hama',
      'ulat',
      'jamur',
      'wereng',
      'gulma',
    ],
  },
];

const STOP_WORDS = new Set([
  'apa',
  'saja',
  'yang',
  'tersedia',
  'sekarang',
  'ada',
  'adakah',
  'berapa',
  'harga',
  'biaya',
  'stok',
  'stock',
  'habis',
  'kosong',
  'produk',
  'barang',
  'jual',
  'dijual',
  'untuk',
  'cocok',
  'rekomendasi',
  'butuh',
  'pakai',
  'gunakan',
  'cara',
  'memakai',
  'membeli',
  'beli',
  'dan',
  'atau',
  'di',
  'ke',
  'dari',
  'ini',
  'itu',
  'saya',
  'kami',
  'kamu',
  'agroshop',
  'benih',
  'bibit',
  'biji',
  'pupuk',
  'alat',
  'tani',
  'pestisida',
  'obat',
]);

@Injectable()
export class ChatbotService {
  constructor(private prisma: PrismaService) {}

  async processMessage(rawMessage: string, history: string[] = []): Promise<{ reply: string; products?: any[] }> {
    const msg = this.normalize(rawMessage);

    if (!msg) {
      return { reply: 'Silakan ketik pertanyaan Anda.' };
    }

    if (this.hasAny(msg, ['halo', 'hai', 'selamat pagi', 'selamat siang', 'selamat sore', 'assalamualaikum'])) {
      return { reply: 'Halo, saya Chatbot Agroshop. Saya bisa membantu menjawab pertanyaan seputar produk pertanian, pupuk, benih, hama tanaman, pesanan, dan pengiriman.' };
    }

    if (this.hasAny(msg, ['terima kasih', 'makasih', 'thanks'])) {
      return { reply: 'Sama-sama. Semoga informasi dari Agroshop membantu kebutuhan pertanian Anda.' };
    }

    const appReply = this.answerApplicationHelp(msg);
    if (appReply) return { reply: appReply };

    const agricultureReply = await this.answerAgricultureAdvice(msg);
    if (agricultureReply) return agricultureReply;

    const productReply = await this.answerProductQuestion(msg);
    if (productReply) return productReply;

    // Jika pesan gagal dikenali, gunakan history untuk konteks tambahan (Memory)
    if (history.length > 0) {
      // Menggabungkan 2 pesan terakhir user + pesan saat ini
      const contextText = history.slice(-2).join(' ') + ' ' + rawMessage;
      const contextMsg = this.normalize(contextText);
      
      const contextAgriReply = await this.answerAgricultureAdvice(contextMsg);
      if (contextAgriReply) return contextAgriReply;
    }

    return { reply: 'Maaf, AgroBot belum menemukan jawaban untuk pertanyaan tersebut di basis pengetahuan kami. Anda bisa menanyakan hal lain seputar pertanian, seperti cara menanam padi, mengatasi hama wereng, atau pertanyaan seputar pesanan Anda.' };
  }

  private normalize(text: string) {
    return text
      .toLowerCase()
      .replace(/cabe/g, 'cabai')
      .replace(/[^\w\s]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private hasAny(text: string, keywords: string[]) {
    return keywords.some((keyword) => this.hasKeyword(text, keyword));
  }

  private hasAll(text: string, keywords: string[]) {
    return keywords.every((keyword) => this.hasKeyword(text, keyword));
  }

  private hasKeyword(text: string, keyword: string) {
    const normalizedKeyword = this.normalize(keyword);

    if (normalizedKeyword.includes(' ')) {
      const words = normalizedKeyword.split(' ');
      // Cukup gunakan includes untuk setiap kata agar toleran terhadap imbuhan (contoh: "padi" cocok dengan "padiku")
      return words.every((w) => text.includes(w));
    }

    // Untuk keyword 1 kata, gunakan includes saja agar lebih fleksibel
    return text.includes(normalizedKeyword);
  }

  private formatCurrency(value: number) {
    return `Rp ${new Intl.NumberFormat('id-ID').format(value)}`;
  }

  private formatPrice(product: any) {
    if (product.discountPrice && product.discountPrice < product.price) {
      return `${this.formatCurrency(product.discountPrice)} (diskon dari ${this.formatCurrency(product.price)})`;
    }

    return this.formatCurrency(product.price);
  }

  private formatProductLine(product: any, showCategory = false) {
    const category = showCategory ? ` [${product.category?.name ?? 'Produk'}]` : '';
    const status = product.isAvailable && product.stock > 0 ? 'tersedia' : 'tidak tersedia';
    return `- ${product.name}${category}: ${this.formatPrice(product)}, stok ${product.stock} ${product.unit} (${status})`;
  }

  private formatProductList(title: string, products: any[], showCategory = false) {
    if (!products.length) return null;

    const list = products
      .map((product) => this.formatProductLine(product, showCategory))
      .join('\n');

    return `${title}\n${list}`;
  }

  private detectCategory(text: string) {
    return CATEGORY_RULES.find((rule) => this.hasAny(text, rule.aliases));
  }

  private extractProductTerms(text: string) {
    const rawWords = text.split(' ');
    const words = rawWords.filter((word) => {
      if (word.length < 3) return false;
      if (STOP_WORDS.has(word)) return false;
      return true;
    });

    return [...new Set(words)];
  }

  private async findProducts(options: {
    categoryLabel?: string;
    terms?: string[];
    take?: number;
    discountedOnly?: boolean;
  }) {
    const take = options.take ?? 6;
    const terms = options.terms ?? [];
    const baseFilters: any[] = [];

    if (options.discountedOnly) {
      baseFilters.push({ discountPrice: { not: null } });
    }

    if (options.categoryLabel && terms.length) {
      const categoryAndName = await this.prisma.product.findMany({
        where: {
          AND: [
            ...baseFilters,
            { category: { name: { contains: options.categoryLabel, mode: 'insensitive' } } },
            { OR: terms.map((term) => ({ name: { contains: term, mode: 'insensitive' } })) },
          ],
        },
        orderBy: { id: 'asc' },
        take,
        select: PRODUCT_SELECT,
      });

      if (categoryAndName.length) return categoryAndName;
    }

    if (terms.length) {
      const byName = await this.prisma.product.findMany({
        where: {
          AND: [
            ...baseFilters,
            { OR: terms.map((term) => ({ name: { contains: term, mode: 'insensitive' } })) },
          ],
        },
        orderBy: { id: 'asc' },
        take,
        select: PRODUCT_SELECT,
      });

      if (byName.length > 0) return byName;
      
      // Lebih fleksibel: Jika nama spesifik tidak ditemukan, TAPI user menyebut kategori (misal: "alat"),
      // izinkan fall-through ke bawah untuk mengambil produk kategori tersebut.
      // Jika tidak ada kategori sama sekali, barulah kembalikan kosong.
      if (!options.categoryLabel) return [];
    }

    if (options.categoryLabel) {
      return this.prisma.product.findMany({
        where: {
          AND: [
            ...baseFilters,
            { category: { name: { contains: options.categoryLabel, mode: 'insensitive' } } },
          ],
        },
        orderBy: { id: 'asc' },
        take,
        select: PRODUCT_SELECT,
      });
    }

    // Hanya kembalikan semua produk jika tidak ada term pencarian dan tidak ada kategori
    return this.prisma.product.findMany({
      where: baseFilters.length ? { AND: baseFilters } : undefined,
      orderBy: { id: 'asc' },
      take,
      select: PRODUCT_SELECT,
    });
  }

  private async answerAgricultureAdvice(msg: string) {
    const allKeywords = await this.prisma.keyword.findMany({
      include: {
        Intent: {
          include: {
            Response: true,
          },
        },
      },
    });

    for (const kw of allKeywords) {
      if (this.hasKeyword(msg, kw.keyword)) {
        const responses = kw.Intent?.Response;
        if (responses && responses.length > 0) {
          // Ambil response pertama
          const res = responses[0];
          let replyText = res.text;
          
          if (res.solution) {
            replyText += '\n\nSolusi: ' + res.solution;
          }

          if (res.recommendProduct) {
            const terms = res.recommendProduct.split(',').map(t => t.trim());
            const products = await this.findProducts({ terms, take: 4 });
            return { reply: replyText, products };
          }

          return { reply: replyText };
        }
      }
    }

    return null;
  }


  private async answerProductQuestion(msg: string) {
    const category = this.detectCategory(msg);
    const terms = this.extractProductTerms(msg);
    const isPriceQuestion = this.hasAny(msg, ['harga', 'berapa', 'biaya']);
    const isStockQuestion = this.hasAny(msg, ['stok', 'stock', 'tersedia', 'habis', 'kosong', 'ada']);
    const isPromoQuestion = this.hasAny(msg, ['promo', 'diskon', 'potongan harga', 'murah']);
    const isCatalogQuestion = this.hasAny(msg, ['produk', 'jual apa', 'barang', 'apa saja', 'katalog', 'cari']) || Boolean(category);
    
    const wordCount = msg.split(' ').length;
    const isLikelyProductSearch = isCatalogQuestion || (terms.length > 0 && wordCount <= 3);

    if (!isLikelyProductSearch && !isPriceQuestion && !isStockQuestion && !isPromoQuestion) {
      return null;
    }

    if (isPromoQuestion) {
      const promoProducts = await this.findProducts({
        categoryLabel: category?.label,
        terms,
        discountedOnly: true,
        take: 6,
      });

      if (!promoProducts.length) {
        return { reply: 'Saat ini belum ada produk diskon yang cocok dengan pertanyaan Anda. Promo biasanya tampil di banner halaman utama atau pada kartu produk.' };
      }
      return { reply: 'Produk yang sedang memiliki harga diskon:', products: promoProducts };
    }

    const products = await this.findProducts({
      categoryLabel: category?.label,
      terms,
      take: terms.length ? 6 : 8,
    });

    if (!products.length) {
      // Hanya kembalikan pesan tidak ada produk jika user eksplisit menanyakan tentang produk/katalog/harga/stok
      const isExplicitProduct = this.hasAny(msg, ['produk', 'jual', 'barang', 'katalog', 'harga', 'berapa', 'biaya', 'stok', 'stock', 'tersedia', 'habis', 'kosong', 'ada', 'promo', 'diskon', 'murah']) || Boolean(category);
      if (isExplicitProduct) {
        return { reply: 'Saya belum menemukan produk yang cocok dengan pertanyaan tersebut di database Agroshop. Coba gunakan nama produk atau kategori seperti benih, pupuk, alat tani, atau pestisida.' };
      }
      return null;
    }

    if (isPriceQuestion) {
      return { reply: 'Berikut informasi harga produk dari database Agroshop:', products };
    }

    if (isStockQuestion) {
      return { reply: 'Berikut informasi stok produk dari database Agroshop:', products };
    }

    const title = category
      ? `Beberapa produk kategori ${category.label} yang tersedia di database Agroshop:`
      : 'Beberapa produk yang tersedia di database Agroshop:';

    return { reply: title, products };
  }

  private answerApplicationHelp(msg: string) {
    if (this.hasAny(msg, ['cara beli', 'membeli', 'order', 'pesan produk'])) {
      return 'Untuk membeli produk, pilih produk yang diinginkan, tambahkan ke keranjang, pilih alamat pengiriman, lalu lakukan checkout.';
    }

    if (this.hasAny(msg, ['checkout', 'keranjang'])) {
      return 'Untuk checkout, buka halaman keranjang, pilih produk yang ingin dibeli, pilih alamat pengiriman, lalu tekan tombol checkout.';
    }

    if (this.hasAny(msg, ['pembayaran', 'transfer', 'metode bayar', 'bayar'])) {
      return 'Untuk saat ini, proses pembayaran mengikuti alur checkout yang tersedia di aplikasi. Jika metode pembayaran sudah ditambahkan, informasinya akan muncul pada halaman checkout.';
    }

    if (this.hasAny(msg, ['lacak', 'tracking', 'resi', 'paket saya', 'pengiriman saya'])) {
      return 'Untuk melacak pesanan, buka menu Profil, pilih Pengiriman atau Riwayat Pesanan, lalu pilih pesanan yang ingin dilihat.';
    }

    if (this.hasAny(msg, ['pengiriman', 'dikirim', 'kurir', 'paket', 'ongkir', 'ongkos kirim'])) {
      return 'Setelah checkout berhasil, pesanan akan masuk ke riwayat pesanan. Jika data pengiriman sudah diperbarui oleh admin, user dapat melihat kurir, nomor resi, dan status pengiriman.';
    }

    if (this.hasAny(msg, ['riwayat', 'pesanan saya', 'order saya', 'belanja saya'])) {
      return 'Riwayat pesanan dapat dilihat melalui menu Profil, lalu pilih Riwayat Pesanan.';
    }

    if (this.hasAny(msg, ['alamat', 'alamat pengiriman', 'rumah', 'lokasi'])) {
      return 'Alamat pengiriman dapat dikelola melalui menu Profil, lalu pilih Alamat Pengiriman. Anda bisa menambah, mengubah, menghapus, dan memilih alamat utama.';
    }

    if (this.hasAny(msg, ['profil', 'data diri', 'akun', 'nama', 'email', 'nomor hp'])) {
      return 'Data diri dapat dilihat dan diubah melalui menu Profil, lalu pilih Data Diri.';
    }

    if (this.hasAny(msg, ['login', 'masuk', 'daftar', 'register', 'akun baru'])) {
      return 'Silakan login terlebih dahulu agar bisa menggunakan fitur keranjang, checkout, alamat pengiriman, dan riwayat pesanan. Jika belum punya akun, gunakan halaman register.';
    }

    if (this.hasAny(msg, ['jam buka', 'jam operasional', 'buka jam', 'tutup jam'])) {
      return 'Agroshop dapat diakses melalui aplikasi kapan saja. Untuk pelayanan admin, silakan mengikuti jadwal operasional yang ditentukan oleh toko.';
    }

    return null;
  }
}
