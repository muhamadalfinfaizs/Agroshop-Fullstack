import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const now = new Date();

  // Add keyword 'cara menanam padi' to 'Sistem Tanam Padi'
  const tanamIntent = await prisma.intent.findFirst({ where: { name: 'Sistem Tanam Padi' } });
  if (tanamIntent) {
    await prisma.keyword.create({
      data: {
        keyword: 'cara menanam padi',
        intentId: tanamIntent.id,
        updatedAt: now,
      }
    });
    console.log('Ditambahkan: cara menanam padi');
  }

  // Add keyword 'keril' to 'Padi Kerdil / Asem-aseman'
  const kerdilIntent = await prisma.intent.findFirst({ where: { name: 'Padi Kerdil / Asem-aseman' } });
  if (kerdilIntent) {
    await prisma.keyword.create({
      data: {
        keyword: 'keril',
        intentId: kerdilIntent.id,
        updatedAt: now,
      }
    });
    console.log('Ditambahkan: keril');
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
