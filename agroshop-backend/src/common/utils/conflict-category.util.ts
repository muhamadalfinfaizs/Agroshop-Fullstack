import { ConflictException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export async function conflictCategory(
  name: string,
  errorMessage: string,
  prisma: PrismaService,
) {
  const existingCategory = await prisma.category.findFirst({
    where: { name: name },
  });

  if (existingCategory) {
    throw new ConflictException({
      success: false,
      message: errorMessage,
      metadata: {
        status: HttpStatus.CONFLICT,
      },
    });
  }

  return name;
}
