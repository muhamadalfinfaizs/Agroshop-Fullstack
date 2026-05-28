import { NotFoundException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function notExistBanner(id: number, prisma: PrismaService) {
  const banner = await prisma.banner.findUnique({
    where: { id: id },
  });

  if (!banner) {
    throw new NotFoundException({
      success: false,
      message: process.env.NOT_DATA || 'Data banner tidak ditemukan',
      metadata: {
        status: HttpStatus.NOT_FOUND,
      },
    });
  }

  return banner;
}
