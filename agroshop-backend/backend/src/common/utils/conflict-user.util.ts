import { ConflictException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function conflictUser(email: string, prisma: PrismaService) {
  const existingUser = await prisma.user.findUnique({
    where: { email: email },
  });

  if (existingUser) {
    throw new ConflictException({
      success: false,
      message: 'Email sudah terdaftar, silakan gunakan email lain',
      metadata: { status: HttpStatus.CONFLICT },
    });
  }
}
