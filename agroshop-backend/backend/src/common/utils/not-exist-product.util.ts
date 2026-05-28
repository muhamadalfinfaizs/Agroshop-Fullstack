import { NotFoundException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function notExistProduct(id: number, prisma: PrismaService) {
  // PENTING: Kita "include" category agar bisa mendapatkan nama kategorinya nanti
  const product = await prisma.product.findUnique({
    where: { id: id },
    include: {
      category: true, // Join tabel category
    },
  });

  if (!product) {
    throw new NotFoundException({
      success: false,
      message: process.env.NOT_DATA || 'Data produk tidak ditemukan',
      metadata: {
        status: HttpStatus.NOT_FOUND,
      },
    });
  }

  return product;
}
