import { NotFoundException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function notExistCategory(id: number, prisma: PrismaService) {
  const category = await prisma.category.findUnique({
    where: { id: id },
  });

  if (!category) {
    throw new NotFoundException({
      success: false,
      message: process.env.NOT_DATA || 'Data kategori tidak ditemukan',
      metadata: {
        status: HttpStatus.NOT_FOUND,
      },
    });
  }

  return category;
}
