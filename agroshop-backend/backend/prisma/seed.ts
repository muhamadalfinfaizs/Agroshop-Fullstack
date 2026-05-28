import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Memulai proses seeding database (dari 0)...');

  // Tidak perlu membersihkan tabel satu per satu karena `migrate reset` 
  // sudah menjatuhkan (drop) dan membuat ulang (recreate) seluruh tabel.
  // Sehingga ID pasti dimulai dari 1.

  // 1. Buat Akun Admin
  console.log('Membuat akun Admin...');
  const hashedPassword = await bcrypt.hash('admin123', 10);
  await prisma.user.create({
    data: {
      name: 'Super Admin',
      email: 'admin@agroshop.test',
      password: hashedPassword,
      role: 'ADMIN',
      phone: '081234567890',
    },
  });

  // 2. Buat Akun Farmer Biasa
  console.log('Membuat akun Farmer...');
  const farmerPassword = await bcrypt.hash('farmer123', 10);
  await prisma.user.create({
    data: {
      name: 'Budi Petani',
      email: 'budi@agroshop.test',
      password: farmerPassword,
      role: 'FARMER',
      phone: '089876543210',
    },
  });

  // 3. Buat Kategori (Gambar menggunakan picsum.photos dengan seed unik)
  console.log('Membuat 4 Kategori...');
  const catBenih = await prisma.category.create({
    data: { name: 'Benih', icon: 'leaf', imageUrl: 'https://picsum.photos/seed/cat_benih/200/200' },
  });
  const catPupuk = await prisma.category.create({
    data: { name: 'Pupuk', icon: 'flask', imageUrl: 'https://picsum.photos/seed/cat_pupuk/200/200' },
  });
  const catAlat = await prisma.category.create({
    data: { name: 'Alat Tani', icon: 'tool', imageUrl: 'https://picsum.photos/seed/cat_alat/200/200' },
  });
  const catObat = await prisma.category.create({
    data: { name: 'Pestisida', icon: 'bug', imageUrl: 'https://picsum.photos/seed/cat_obat/200/200' },
  });

  // 4. Buat Produk
  console.log('Membuat 20 Produk (5 per kategori)...');
  
  // Produk Benih
  const benihs = [
    { name: 'Benih Padi Hibrida', price: 75000, discountPrice: 70000, stock: 150, unit: 'kg' },
    { name: 'Benih Jagung Manis', price: 45000, discountPrice: null, stock: 80, unit: 'pouch' },
    { name: 'Benih Tomat Sayur', price: 15000, discountPrice: null, stock: 200, unit: 'sachet' },
    { name: 'Benih Cabai Rawit Merah', price: 25000, discountPrice: 22000, stock: 120, unit: 'sachet' },
    { name: 'Benih Kacang Panjang', price: 12000, discountPrice: null, stock: 90, unit: 'sachet' },
  ];
  let i = 1;
  for (const p of benihs) {
    await prisma.product.create({
      data: {
        ...p,
        description: `Produk ${p.name} unggulan dengan kualitas terbaik untuk hasil panen maksimal.`,
        imageUrl: `https://picsum.photos/seed/benih_${i}/800/800`,
        categoryId: catBenih.id,
      },
    });
    i++;
  }

  // Produk Pupuk
  const pupuks = [
    { name: 'Pupuk NPK Mutiara', price: 18000, discountPrice: 17500, stock: 500, unit: 'kg' },
    { name: 'Pupuk Urea Non-Subsidi', price: 12000, discountPrice: null, stock: 1000, unit: 'kg' },
    { name: 'Pupuk Kompos Organik', price: 25000, discountPrice: 20000, stock: 300, unit: 'karung' },
    { name: 'Pupuk Cair Daun', price: 45000, discountPrice: null, stock: 50, unit: 'botol' },
    { name: 'Pupuk Kandang Sapi', price: 15000, discountPrice: null, stock: 200, unit: 'karung' },
  ];
  i = 1;
  for (const p of pupuks) {
    await prisma.product.create({
      data: {
        ...p,
        description: `Produk ${p.name} untuk menyuburkan tanah dan mempercepat pertumbuhan.`,
        imageUrl: `https://picsum.photos/seed/pupuk_${i}/800/800`,
        categoryId: catPupuk.id,
      },
    });
    i++;
  }

  // Produk Alat Tani
  const alats = [
    { name: 'Cangkul Baja Asli', price: 85000, discountPrice: 80000, stock: 40, unit: 'pcs' },
    { name: 'Sabit Rumput Tajam', price: 45000, discountPrice: null, stock: 60, unit: 'pcs' },
    { name: 'Sprayer Elektrik 16L', price: 450000, discountPrice: 420000, stock: 15, unit: 'unit' },
    { name: 'Selang Air 20 Meter', price: 120000, discountPrice: null, stock: 30, unit: 'roll' },
    { name: 'Gunting Dahan Pruning', price: 55000, discountPrice: null, stock: 100, unit: 'pcs' },
  ];
  i = 1;
  for (const p of alats) {
    await prisma.product.create({
      data: {
        ...p,
        description: `${p.name} kuat dan tahan lama, mempermudah pekerjaan Anda di ladang.`,
        imageUrl: `https://picsum.photos/seed/alat_${i}/800/800`,
        categoryId: catAlat.id,
      },
    });
    i++;
  }

  // Produk Pestisida
  const obats = [
    { name: 'Insektisida Pembasmi Ulat', price: 65000, discountPrice: 60000, stock: 80, unit: 'botol' },
    { name: 'Herbisida Rumput Liar', price: 75000, discountPrice: null, stock: 120, unit: 'liter' },
    { name: 'Fungisida Anti Jamur', price: 55000, discountPrice: null, stock: 90, unit: 'botol' },
    { name: 'Obat Hama Wereng', price: 85000, discountPrice: 82000, stock: 50, unit: 'sachet' },
    { name: 'Vitamin Anti Stres Tanaman', price: 40000, discountPrice: null, stock: 200, unit: 'botol' },
  ];
  i = 1;
  for (const p of obats) {
    await prisma.product.create({
      data: {
        ...p,
        description: `${p.name} ampuh melindungi tanaman dari serangan hama dan penyakit.`,
        imageUrl: `https://picsum.photos/seed/obat_${i}/800/800`,
        categoryId: catObat.id,
      },
    });
    i++;
  }

  // 5. Buat Banner
  console.log('Membuat 3 Banner...');
  await prisma.banner.createMany({
    data: [
      {
        title: 'Promo Musim Tanam',
        subtitle: 'Diskon Spesial Benih & Pupuk hingga 20%',
        imageUrl: 'https://picsum.photos/seed/banner1/1024/512',
      },
      {
        title: 'Peralatan Bertani Modern',
        subtitle: 'Tingkatkan efisiensi kerja Anda',
        imageUrl: 'https://picsum.photos/seed/banner2/1024/512',
      },
      {
        title: 'Bebas Hama & Penyakit',
        subtitle: 'Pestisida ampuh lindungi panen Anda',
        imageUrl: 'https://picsum.photos/seed/banner3/1024/512',
      },
    ],
  });

  console.log('✅ Proses seeding selesai!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
