import { ConflictException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function conflictBanner(
  title: string,
  errorMessage: string,
  prisma: PrismaService,
) {
  const existingBanner = await prisma.banner.findFirst({
    where: { title: title },
  });

  if (existingBanner) {
    throw new ConflictException({
      success: false,
      message: errorMessage,
      metadata: {
        status: HttpStatus.CONFLICT,
      },
    });
  }

  return title;
}
