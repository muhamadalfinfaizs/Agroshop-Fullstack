import { NotFoundException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function notExistUser(id: number, prisma: PrismaService) {
  const user = await prisma.user.findUnique({ where: { id: id } });
  if (!user) {
    throw new NotFoundException({
      success: false,
      message: 'User tidak ditemukan',
      metadata: { status: HttpStatus.NOT_FOUND },
    });
  }
  return user;
}
