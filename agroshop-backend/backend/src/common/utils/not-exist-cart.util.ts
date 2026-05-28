import { NotFoundException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function notExistCart(id: number, prisma: PrismaService) {
  const cartItem = await prisma.cartItem.findUnique({
    where: { id: id },
  });

  if (!cartItem) {
    throw new NotFoundException({
      success: false,
      message: 'Data keranjang tidak ditemukan',
      metadata: { status: HttpStatus.NOT_FOUND },
    });
  }

  return cartItem;
}
