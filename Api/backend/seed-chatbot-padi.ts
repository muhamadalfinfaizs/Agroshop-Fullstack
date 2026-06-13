import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const padiIntents = [
  {
    name: 'Pemilihan Benih Padi',
    description: 'Panduan memilih benih padi yang baik',
    keywords: ['benih padi', 'bibit padi', 'pilih benih', 'benih unggul padi', 'bibit unggul'],
    text: 'Untuk benih padi, pastikan Anda memilih benih unggul bersertifikat yang tahan terhadap hama dan penyakit lokal. Lakukan perendaman benih dalam larutan garam untuk memisahkan benih yang hampa (mengapung) dan benih yang bernas (tenggelam).',
    recommendProduct: 'benih padi',
  },
  {
    name: 'Persiapan Lahan Sawah',
    description: 'Cara mengolah tanah sawah sebelum tanam',
    keywords: ['persiapan lahan', 'bajak sawah', 'olah tanah', 'traktor sawah', 'sebelum tanam padi'],
    text: 'Persiapan lahan sawah dilakukan dengan membajak tanah untuk membalikkan lapisan tanah, diikuti dengan penggaruan agar tanah menjadi lumpur yang rata. Biarkan lahan selama 1-2 minggu agar sisa tanaman membusuk sempurna sebelum penanaman.',
  },
  {
    name: 'Sistem Tanam Padi',
    description: 'Jarak tanam dan sistem jajar legowo',
    keywords: ['jarak tanam', 'jajar legowo', 'cara tanam padi', 'sistem tanam', 'jarak padi'],
    text: 'Sangat disarankan menggunakan sistem tanam Jajar Legowo (misalnya 2:1 atau 4:1). Sistem ini memberikan ruang terbuka yang lebih banyak sehingga sirkulasi udara dan cahaya matahari optimal, mengurangi risiko penyakit, dan memudahkan perawatan serta pemupukan.',
  },
  {
    name: 'Jadwal Pemupukan Padi',
    description: 'Waktu dan jenis pupuk untuk padi',
    keywords: ['pemupukan padi', 'pupuk padi', 'kapan mupuk padi', 'jadwal pupuk', 'pupuk urea padi', 'pupuk npk padi'],
    text: 'Pemupukan padi umumnya dilakukan 3 kali: \n1. Pupuk dasar (0-7 HST): Gunakan NPK dan Urea.\n2. Susulan pertama (14-20 HST): Gunakan Urea untuk memacu anakan.\n3. Susulan kedua (30-35 HST): Gunakan Urea dan KCl (atau NPK) untuk persiapan masa berbunga (primordia).',
    recommendProduct: 'pupuk urea, pupuk npk',
  },
  {
    name: 'Hama Wereng Coklat Padi',
    description: 'Mengatasi hama wereng pada padi',
    keywords: ['wereng', 'wereng coklat', 'hama wereng', 'wereng padi', 'padi kering', 'hopperburn'],
    text: 'Hama wereng coklat menghisap cairan batang padi hingga tanaman menguning dan kering (hopperburn). Cara mengatasinya: gunakan varietas tahan wereng, amati sawah secara rutin, gunakan musuh alami (laba-laba), dan gunakan insektisida sistemik berbahan aktif buprofezin atau imidakloprid jika serangan parah.',
    solution: 'Semprotkan insektisida sistemik khusus wereng ke bagian pangkal batang padi.',
    recommendProduct: 'insektisida wereng',
  },
  {
    name: 'Hama Penggerek Batang Padi (Sundep/Beluk)',
    description: 'Mengatasi ulat penggerek batang',
    keywords: ['sundep', 'beluk', 'penggerek batang', 'ulat batang', 'ulat padi', 'pucuk kering', 'malai hampa'],
    text: 'Penggerek batang menyebabkan pucuk padi layu/kering (sundep) pada masa vegetatif, dan malai putih hampa (beluk) pada masa generatif. Pencegahannya adalah dengan pengaturan pola tanam serempak, mengumpulkan kelompok telur ngengat di persemaian, dan aplikasi insektisida (misal: karbofuran, fipronil) bila perlu.',
    solution: 'Gunakan insektisida tabur atau semprot saat kupu-kupu putih mulai terlihat di sawah.',
    recommendProduct: 'insektisida ulat',
  },
  {
    name: 'Hama Walang Sangit',
    description: 'Mengatasi hama walang sangit yang menyerang bulir padi',
    keywords: ['walang sangit', 'padi bau', 'bulir kosong', 'hama bau', 'bulir hampa'],
    text: 'Walang sangit menyerang dengan menghisap cairan bulir padi yang sedang pada fase masak susu, menyebabkan bulir menjadi hampa atau berwarna kehitaman. Kendalikan dengan menjaga kebersihan gulma, memasang umpan bangkai kepiting/keong, atau menggunakan insektisida kontak berbahan aktif BPMC pada pagi/sore hari.',
    solution: 'Semprot insektisida pada pagi atau sore hari saat walang sangit aktif.',
    recommendProduct: 'insektisida',
  },
  {
    name: 'Penyakit Blas / Potong Leher',
    description: 'Mengatasi jamur Pyricularia oryzae',
    keywords: ['blas', 'potong leher', 'jamur padi', 'bercak belah ketupat', 'leher malai patah', 'padi patah'],
    text: 'Penyakit blas disebabkan oleh jamur. Gejalanya berupa bercak daun berbentuk belah ketupat (leaf blast) atau busuk pada pangkal malai hingga malai patah (neck blast/potong leher). Hindari pupuk nitrogen (Urea) berlebihan dan gunakan fungisida berbahan aktif trisiklazol, difenokonazol, atau benomil.',
    solution: 'Semprotkan fungisida segera saat terlihat gejala bercak daun, kurangi dosis pupuk Urea.',
    recommendProduct: 'fungisida blas, fungisida',
  },
  {
    name: 'Penyakit Hawar Daun Bakteri (Kresek)',
    description: 'Mengatasi penyakit kresek',
    keywords: ['kresek', 'hawar daun', 'bakteri padi', 'daun kuning padi', 'daun mengering dari ujung', 'xanthomonas'],
    text: 'Penyakit kresek (Hawar Daun Bakteri) menyebabkan tepi daun menguning, bergelombang, lalu mengering dari ujung. Sangat rentan menular saat musim hujan atau angin kencang. Hindari penggunaan pupuk N (Urea) secara berlebihan, dan gunakan bakterisida berbahan aktif tembaga (copper) atau streptomisin.',
    solution: 'Jangan aplikasikan pupuk Urea saat serangan kresek tinggi, gunakan bakterisida.',
    recommendProduct: 'bakterisida',
  },
  {
    name: 'Pengendalian Gulma Sawah',
    description: 'Mengatasi rumput liar di sawah',
    keywords: ['gulma', 'rumput sawah', 'rumput padi', 'herbisida padi', 'pembasmi rumput', 'jajagoan'],
    text: 'Gulma atau rumput liar bersaing dengan padi dalam mengambil nutrisi. Pengendalian bisa dilakukan secara manual (matun), menggunakan alat landak, atau penyemprotan herbisida selektif (pra-tumbuh atau purna-tumbuh) yang aman bagi padi.',
    recommendProduct: 'herbisida selektif padi, herbisida',
  },
  {
    name: 'Padi Kerdil / Asem-aseman',
    description: 'Mengatasi padi yang tidak mau tumbuh atau kerdil',
    keywords: ['padi kerdil', 'asem-aseman', 'padi merah', 'akar karat', 'tidak mau tumbuh', 'padi kuning kerdil'],
    text: 'Gejala asem-aseman (keracunan besi/H2S) sering terjadi pada lahan yang terus tergenang air dengan sisa jerami yang belum lapuk. Akar padi berwarna kecoklatan seperti karat dan tanaman kerdil. Cara mengatasinya: keringkan sawah (macak-macak), dan aplikasikan pupuk Zinc (Seng) atau kapur dolomit.',
    solution: 'Kuras air sawah dan biarkan mengering (macak-macak) selama beberapa hari untuk membuang gas beracun.',
    recommendProduct: 'pupuk zinc, pupuk mikro',
  },
  {
    name: 'Kebutuhan Air dan Irigasi Padi',
    description: 'Manajemen pengairan sawah',
    keywords: ['pengairan sawah', 'kebutuhan air padi', 'irigasi', 'keringkan sawah', 'air padi'],
    text: 'Padi bukanlah tanaman air, melainkan tanaman yang toleran terhadap genangan. Terapkan sistem irigasi berselang (AWD / Alternate Wetting and Drying) yaitu membiarkan sawah tergenang lalu mengering berkali-kali. Ini merangsang akar padi tumbuh lebih dalam dan mencegah penyakit.',
  },
  {
    name: 'Ciri-Ciri Padi Siap Panen',
    description: 'Kapan padi bisa dipanen',
    keywords: ['panen padi', 'siap panen', 'kapan panen', 'umur panen', 'padi menguning', 'ciri panen'],
    text: 'Padi siap dipanen jika 90-95% gabah pada malai sudah menguning, daun bendera mulai mengering, dan umur tanaman sudah mencapai standar deskripsi varietasnya (biasanya 90-115 hari setelah tanam). Panen tepat waktu mencegah gabah rontok di sawah.',
  }
];

async function main() {
  console.log('Memulai seeder pengetahuan padi...');
  let added = 0;

  for (const item of padiIntents) {
    const now = new Date();
    
    // Check if intent already exists
    const existing = await prisma.intent.findUnique({
      where: { name: item.name },
    });

    if (!existing) {
      await prisma.intent.create({
        data: {
          name: item.name,
          description: item.description,
          updatedAt: now,
          Keyword: {
            create: item.keywords.map((kw) => ({ keyword: kw, updatedAt: now })),
          },
          Response: {
            create: [
              {
                text: item.text,
                solution: item.solution,
                recommendProduct: item.recommendProduct,
                updatedAt: now,
              },
            ],
          },
        },
      });
      console.log(`+ Berhasil menambahkan intent: ${item.name}`);
      added++;
    } else {
      console.log(`- Intent sudah ada: ${item.name}`);
    }
  }

  console.log(`Selesai! Berhasil menambahkan ${added} pengetahuan baru tentang padi.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
